import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/property.dart';
import '../widgets/infosheet.dart';
import 'home_screen.dart';
import 'preference_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  NaverMapController? _mapController;
  List<Property> _properties = [];
  List<NMarker> _markers = [];
  bool _loading = false;
  final Map<String, Property> _markerIdToProperty = {};

  @override
  void initState() {
    super.initState();
    _fetchPropertiesAndMarkers();
  }

  Future<void> _fetchPropertiesAndMarkers() async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/properties'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Property> properties = [];
        List<NMarker> markers = [];
        final markerIdToProperty = <String, Property>{};
        for (var item in data) {
          final property = Property(
            image: item['image'] ?? '',
            address: item['address'] ?? '',
            type: item['type'] ?? '',
            floor: int.tryParse(item['floor']?.toString() ?? '0') ?? 0,
            area: double.tryParse(item['area']?.toString() ?? '0') ?? 0.0,
            price: int.tryParse(item['price']?.toString() ?? '0') ?? 0,
            options: item['options'] ?? '',
            contact: item['contact'] ?? '',
            tags:
                (item['tags'] is String)
                    ? (item['tags'] as String)
                        .split(',')
                        .map((e) => e.trim())
                        .toList()
                    : (item['tags'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [],
            isFavorite: item['isFavorite'] ?? false,
          );
          properties.add(property);
          // 주소를 좌표로 변환
          final latLng = await fetchLatLngFromAddress(property.address);
          if (latLng != null) {
            final markerId = property.address + property.contact;
            final marker = NMarker(
              id: markerId,
              position: NLatLng(latLng[0], latLng[1]),
              caption: NOverlayCaption(text: property.type),
            );
            marker.setOnTapListener((NMarker marker) {
              _showInfoSheet(context, property);
            });
            markers.add(marker);
            markerIdToProperty[markerId] = property;
          }
        }
        setState(() {
          _properties = properties;
          _markers = markers;
          _markerIdToProperty.clear();
          _markerIdToProperty.addAll(markerIdToProperty);
        });
        // 지도에 마커 추가
        if (_mapController != null) {
          _mapController!.clearOverlays();
          _mapController!.addOverlayAll(_markers.toSet());
        }
      }
    } catch (e) {
      // ignore
    }
    setState(() {
      _loading = false;
    });
  }

  // 네이버 Geocoding API 호출 함수
  Future<List<double>?> fetchLatLngFromAddress(String address) async {
    if (address.trim().isEmpty) return null;
    final apiUrl =
        'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=${Uri.encodeComponent(address)}';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': '여기에_본인_CLIENT_ID',
        'X-NCP-APIGW-API-KEY': '여기에_본인_CLIENT_SECRET',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['addresses'] != null && data['addresses'].isNotEmpty) {
        final addr = data['addresses'][0];
        double lat = double.parse(addr['y']);
        double lng = double.parse(addr['x']);
        return [lat, lng];
      }
    }
    return null;
  }

  void _showInfoSheet(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InfoSheet(property: property),
    );
  }

  Future<void> _searchAndMove(String address) async {
    if (address.trim().isEmpty) return;
    final latLng = await fetchLatLngFromAddress(address);
    if (latLng != null && _mapController != null) {
      _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(latLng[0], latLng[1]),
          zoom: 16,
        ),
      );
      // 검색 위치에 마커 추가
      final marker = NMarker(
        id: 'search_marker_${DateTime.now().millisecondsSinceEpoch}',
        position: NLatLng(latLng[0], latLng[1]),
        caption: NOverlayCaption(text: address),
      );
      marker.setOnTapListener((NMarker marker) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('검색한 위치로 이동'),
                  ],
                ),
              ),
        );
      });
      setState(() {
        _markers.add(marker);
      });
      _mapController!.addOverlay(marker);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('주소를 찾을 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '도로명주소 검색',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                  ),
                  onSubmitted: (value) => _searchAndMove(value),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey),
                onPressed: () => _searchAndMove(_searchController.text),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          NaverMap(
            onMapReady: (controller) async {
              _mapController = controller;
              // 지도 준비 완료 시 마커 추가
              if (_markers.isNotEmpty) {
                _mapController!.addOverlayAll(_markers.toSet());
              }
            },
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.3595704, 127.105399),
                zoom: 10,
              ),
            ),
          ),
          if (_loading) Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Preference',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          } else if (index == 1) {
            // 이미 Map이므로 아무것도 안 해도 됨
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PreferenceScreen()),
            );
          }
        },
      ),
    );
  }
}

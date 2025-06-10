import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../data/models/property.dart';
import '../../widgets/property_card.dart';
import '../../data/datasources/property_api.dart';
import '../../viewmodel/property_viewmodel.dart';

class MapView extends StatefulWidget {
  final NLatLng? focusPosition;
  final List<String>? matchedPropertyIds;
  final String? matchedCustomerName;
  const MapView({
    Key? key,
    this.focusPosition,
    this.matchedPropertyIds,
    this.matchedCustomerName,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TextEditingController _searchController = TextEditingController();
  NaverMapController? _mapController;
  List<Property> _properties = [];
  List<NMarker> _markers = [];
  bool _loading = false;
  final Map<String, Property> _markerIdToProperty = {};
  NLatLng? _initialPosition;
  double _initialZoom = 16;
  NCameraPosition? _lastCameraPosition;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    _setInitialPositionFromGPS();
    final viewModel = Provider.of<PropertyViewModel>(context, listen: false);
    viewModel.fetchPropertiesAndMatches(viewModel.matchRepository).then((_) {
      viewModel.generateMarkers(
        matchedPropertyIds: widget.matchedPropertyIds,
        matchedCustomerName: widget.matchedCustomerName,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _showInfoSheet(
    BuildContext context,
    Property property, {
    bool isMatched = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => InfoSheet(
            property: property,
            fromMapView: true,
            isMatched: isMatched,
          ),
    );
  }

  Future<void> _searchAndMove(String address) async {
    // 주소 → 좌표 변환 (geocoding)
    final latLng = await geocodeAddress(address);
    if (latLng != null && _mapController != null) {
      _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(target: latLng, zoom: _initialZoom),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('주소를 찾을 수 없습니다.')));
    }
  }

  // 앱 최초 실행 시 GPS로 위치 설정
  Future<void> _setInitialPositionFromGPS() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      print('현재 위치: ${position.latitude}, ${position.longitude}');
      setState(() {
        _initialPosition = NLatLng(position.latitude, position.longitude);
      });
      if (_mapController != null && _initialPosition != null) {
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: _initialPosition!,
            zoom: _initialZoom,
          ),
        );
      }
    } catch (e) {
      print('위치 정보 가져오기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('위치 정보를 가져올 수 없습니다: $e')));
      }
    }
  }

  // 지도 이동/줌 변경 시 마지막 위치 저장
  void _onCameraChange(NCameraPosition position) {
    _lastCameraPosition = position;
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한 거부됨
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 권한이 필요합니다.')), // 한글 안내
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // 영구적으로 거부됨
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('설정에서 위치 권한을 허용해주세요.')), // 한글 안내
      );
      return;
    }
    // 권한 허용됨, 위치 사용 가능
  }

  Future<NLatLng?> geocodeAddress(String address) async {
    final apiKey = dotenv.env['NMF_CLIENT_ID'] ?? '';
    final apiSecret = dotenv.env['NMF_CLIENT_SECRET_ID'] ?? '';
    final url = Uri.parse(
      'https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=${Uri.encodeComponent(address)}',
    );
    final response = await http.get(
      url,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': apiKey,
        'X-NCP-APIGW-API-KEY': apiSecret,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['addresses'] != null && data['addresses'].isNotEmpty) {
        final addr = data['addresses'][0];
        final lat = double.parse(addr['y']);
        final lng = double.parse(addr['x']);
        return NLatLng(lat, lng);
      }
    }
    return null;
  }

  // 외부에서 지도 카메라를 이동시키는 메서드
  void moveTo(double lat, double lng) {
    if (_mapController != null) {
      _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(lat, lng),
          zoom: _initialZoom,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PropertyViewModel>(context);
    final properties = viewModel.properties;
    final markers = viewModel.markers;
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: SafeArea(
        child: Stack(
          children: [
            NaverMap(
              onMapReady: (controller) async {
                _mapController = controller;
                // 지도 준비 완료 시 ViewModel의 마커 추가
                if (markers.isNotEmpty) {
                  _mapController!.addOverlayAll(markers.toSet());
                }
                // focusPosition이 있으면 카메라 이동
                if (widget.focusPosition != null) {
                  _mapController!.updateCamera(
                    NCameraUpdate.scrollAndZoomTo(
                      target: widget.focusPosition!,
                      zoom: _initialZoom,
                    ),
                  );
                } else if (_initialPosition != null) {
                  _mapController!.updateCamera(
                    NCameraUpdate.scrollAndZoomTo(
                      target: _initialPosition!,
                      zoom: _initialZoom,
                    ),
                  );
                }
              },
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _initialPosition ?? NLatLng(37.3595704, 127.105399),
                  zoom: _initialZoom,
                ),
              ),
            ),
            if (viewModel.isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

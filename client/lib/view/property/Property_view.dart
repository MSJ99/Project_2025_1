import 'package:flutter/material.dart';
import '../../data/models/property.dart';
import '../../widgets/property_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/property_viewmodel.dart';
import 'add_view.dart';
import 'edit_view.dart';
import '../../widgets/property_card.dart';
import '../../widgets/property_card.dart' show InfoSheet;

enum CompareOp { greater, equal, less }

class _Filter {
  String? tradeType;
  CompareOp? floorOp;
  int? floorValue;
  CompareOp? areaOp;
  double? areaValue;
  CompareOp? priceOp;
  int? priceValue;

  _Filter();
}

typedef MapMoveCallback = void Function(double lat, double lng);

class PropertyView extends StatefulWidget {
  final MapMoveCallback? onMapMove;
  PropertyView({Key? key, this.onMapMove}) : super(key: key);

  @override
  State<PropertyView> createState() => PropertyViewState();
}

class PropertyViewState extends State<PropertyView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _Filter _filter = _Filter();

  @override
  void initState() {
    super.initState();
    // Provider의 ViewModel에서 fetchProperties 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 예시: 부모에서 콜백을 연결해주는 구조 필요
    // widget.onMapMove = (lat, lng) {
    //   // 예: 탭 인덱스 변경 및 지도 카메라 이동
    //   // MainTabState.of(context)?.moveToMapAndCamera(lat, lng);
    // };
  }

  List<Property> getFilteredProperties(List<Property> properties) {
    if (_searchQuery.isEmpty) return properties;
    final query = _searchQuery.toLowerCase();
    return properties.where((p) {
      final addressMatch = p.address.toLowerCase().contains(query);
      final tagMatch = p.options.any(
        (tag) => tag.toLowerCase().contains(query),
      );
      return addressMatch || tagMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PropertyViewModel>(context);
    final filteredProperties = getFilteredProperties(viewModel.properties);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: '검색',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchQuery = _searchController.text;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // 리스트
            Expanded(
              child:
                  viewModel.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredProperties.length,
                        itemBuilder: (context, index) {
                          final property = filteredProperties[index];
                          final matchedCount =
                              viewModel.matchedDemandCountByPropertyId[property
                                  .id] ??
                              0;
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (context) => InfoSheet(property: property),
                              );
                            },
                            child: PropertyCard(property: property),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PropertyAddView()),
          );
          if (result == true) {
            Provider.of<PropertyViewModel>(
              context,
              listen: false,
            ).fetchProperties();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  static PropertyViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<PropertyViewState>();
  }
}

String getImageUrl(String imagePath, String backendIp, String backendPort) {
  if (imagePath.startsWith('http')) return imagePath;
  if (imagePath.startsWith('/')) {
    return 'http://$backendIp:$backendPort$imagePath';
  }
  return 'http://$backendIp:$backendPort/$imagePath';
}

// 매물 카드 위젯
class _PropertyCard extends StatelessWidget {
  final Property property;
  final int matchedCount;
  const _PropertyCard({required this.property, required this.matchedCount});

  @override
  Widget build(BuildContext context) {
    final backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
    final backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditView(property: property.toJson()),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (matchedCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Chip(
                  label: Text(
                    '매칭됨',
                    style: TextStyle(color: Colors.green[900]),
                  ),
                  backgroundColor: Colors.green[100],
                ),
              ),
            // 주소
            Text(
              property.address,
              style: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // 이미지
            if (property.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  getImageUrl(property.image, backendIp, backendPort),
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            // 거래종류, 건물유형, 층수, 평수, 가격 등
            Text('거래종류: ${property.tradeType}'),
            Text('건물 유형: ${property.propertyType}'),
            Text('보증금: ${property.price}원'),
            if (property.monthlyRent != null && property.monthlyRent != 0)
              Text('월세: ${property.monthlyRent}원'),
            Text('층수: ${property.floor}'),
            Text('방 개수: ${property.roomCount}'),
            Text('평수: ${property.area}'),
            Text(
              '입주 가능일: ${property.moveInDate.toIso8601String().split('T').first}',
            ),
            Text('연락처: ${property.contact}'),
            const SizedBox(height: 8),
            if (property.options.isNotEmpty)
              Wrap(
                spacing: 8,
                children:
                    property.options
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

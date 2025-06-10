import 'package:flutter/material.dart';
import '../data/models/property.dart';
import '../view/property/edit_view.dart';
import '../view/map/map_view.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../view/property/Property_view.dart'
    show PropertyView, PropertyViewState;

class InfoSheet extends StatelessWidget {
  final Property property;
  final bool fromMapView;
  final bool isMatched;
  const InfoSheet({
    required this.property,
    this.fromMapView = false,
    this.isMatched = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
    final backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';
    final imageUrl =
        property.image.isNotEmpty
            ? (property.image.startsWith('http')
                ? property.image
                : 'http://$backendIp:$backendPort/${property.image}')
            : null;
    final highlightStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red,
    );
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          imageUrl != null
                              ? Image.network(
                                imageUrl,
                                width: 200,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                              )
                              : Container(
                                width: 200,
                                height: 150,
                                color: const Color(0xFFF5F5F5),
                                child: const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 주소
                  Text(
                    property.address,
                    style:
                        isMatched
                            ? highlightStyle.copyWith(fontSize: 20)
                            : const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 8),
                  // 거래종류
                  Text(
                    '거래종류: ${property.tradeType}',
                    style: isMatched ? highlightStyle : null,
                  ),
                  // 건물 유형
                  Text(
                    '건물 유형: ${property.propertyType}',
                    style: isMatched ? highlightStyle : null,
                  ),
                  // 보증금
                  Text(
                    '보증금: ${property.price}원',
                    style: isMatched ? highlightStyle : null,
                  ),
                  // 월세
                  if (property.monthlyRent != null && property.monthlyRent != 0)
                    Text(
                      '월세: ${property.monthlyRent}원',
                      style: isMatched ? highlightStyle : null,
                    ),
                  // 층수
                  Text(
                    '층수: ${property.floor}',
                    style: isMatched ? highlightStyle : null,
                  ),
                  // 방 개수
                  Text(
                    '방 개수: ${property.roomCount}',
                    style: isMatched ? highlightStyle : null,
                  ),
                  // 평수
                  Text(
                    '평수: ${property.area}',
                    style: isMatched ? highlightStyle : null,
                  ),
                  // 입주 가능일
                  Text(
                    '입주 가능일: '
                    '${property.moveInDate.toIso8601String().split('T').first}',
                    style: isMatched ? highlightStyle : null,
                  ),
                  // 연락처
                  Text(
                    '연락처: ${property.contact}',
                    style: isMatched ? highlightStyle : null,
                  ),
                  const SizedBox(height: 8),
                  // 태그(옵션)
                  if (property.options.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children:
                          property.options
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                    ),
                  const SizedBox(height: 16),
                  // Edit, Undo 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // InfoSheet 닫기
                          final propertyId =
                              property.id ??
                              property.toJson()['id']?.toString() ??
                              property.toJson()['_id']?.toString() ??
                              '';
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => EditView(
                                    property: {
                                      'id': propertyId,
                                      'imagePath': property.image,
                                      'address': property.address,
                                      'trade_type': property.tradeType,
                                      'floor': property.floor,
                                      'area': property.area,
                                      'price': property.price,
                                      'options': property.options.join(','),
                                      'contact': property.contact,
                                      'monthlyRent': property.monthlyRent,
                                    },
                                  ),
                            ),
                          );
                        },
                        child: const Text('Edit'),
                      ),
                      if (fromMapView)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('뒤로 가기'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({required this.property, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
    final backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';
    final imageUrl =
        property.image.isNotEmpty
            ? (property.image.startsWith('http')
                ? property.image
                : 'http://$backendIp:$backendPort/${property.image}')
            : null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 상단 크게
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  imageUrl != null
                      ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                      )
                      : Container(
                        width: double.infinity,
                        height: 180,
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            // 주소
            Text(
              property.address,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // 옵션(Chip)
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

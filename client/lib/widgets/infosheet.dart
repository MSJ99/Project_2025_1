import 'package:flutter/material.dart';
import '../models/property.dart';
import '../screens/edit_screen.dart';

class InfoSheet extends StatelessWidget {
  final Property property;
  const InfoSheet({required this.property, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      child: Image.asset(
                        property.image.isNotEmpty
                            ? property.image
                            : 'lib/assets/default_image.png',
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 주소
                  Text(
                    property.address,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 종류, 층수, 평수, 가격, 옵션, 연락처
                  Text('종류: ${property.type}'),
                  Text('층수: ${property.floor}층'),
                  Text('평수: ${property.area}평'),
                  Text('가격: ${property.price}원'),
                  Text('옵션: ${property.options}'),
                  Text('연락처: ${property.contact}'),
                  const SizedBox(height: 8),
                  // 태그
                  Wrap(
                    spacing: 8,
                    children:
                        property.tags
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  // 즐겨찾기 여부
                  Row(
                    children: [
                      Icon(
                        property.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: property.isFavorite ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(property.isFavorite ? '즐겨찾기됨' : '즐겨찾기 아님'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Edit, Undo 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // InfoSheet 닫기
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => EditScreen(
                                    property: {
                                      'imagePath': property.image,
                                      'address': property.address,
                                      'type': property.type,
                                      'floor': property.floor,
                                      'area': property.area,
                                      'price': property.price,
                                      'options': property.options,
                                      'contact': property.contact,
                                      'tags': property.tags.join(','),
                                      'isFavorite': property.isFavorite,
                                    },
                                  ),
                            ),
                          );
                        },
                        child: const Text('Edit'),
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

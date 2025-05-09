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
                  // 이미지, 주소, 종류, 층수, 평수, 가격, 옵션, 연락처, 태그, isFavorite 등 상세 정보 표시
                  // ...
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
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Info 창 닫기(Undo)
                        },
                        child: const Text('Undo'),
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

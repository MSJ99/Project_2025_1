import 'package:flutter/material.dart';
import '../models/property.dart';
import '../widgets/infosheet.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  void _showInfoSheet(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InfoSheet(property: property),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 임시 더미 매물 데이터
    final dummyProperty = Property(
      image: '',
      address: '서울시 강남구 테헤란로 123',
      type: '오피스텔',
      floor: 10,
      area: 25.0,
      price: 30000,
      options: '풀옵션',
      contact: '010-1234-5678',
      tags: ['신축', '역세권'],
      isFavorite: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // TODO: 네이버 지도 API 연동 (현재는 임시 컨테이너)
          Container(
            color: const Color(0xFFE0E0E0),
            child: const Center(
              child: Text(
                '여기에 네이버 지도가 표시됩니다.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
          // 임시 마커(버튼) - 실제로는 지도 위에 마커가 있어야 함
          Positioned(
            left: 100,
            top: 200,
            child: GestureDetector(
              onTap: () => _showInfoSheet(context, dummyProperty),
              child: const Icon(Icons.location_on, size: 48, color: Colors.red),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'searchBtn',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 2,
              onPressed: () {
                // TODO: [Search Address] 화면으로 이동
              },
              child: const Icon(Icons.search),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Preference',
          ),
        ],
        currentIndex: 1, // Map이 현재 선택됨
        onTap: (index) {
          // TODO: 각 화면으로 이동
        },
      ),
    );
  }
}

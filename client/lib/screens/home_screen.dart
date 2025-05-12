import 'package:flutter/material.dart';
import '../models/property.dart';
import '../widgets/infosheet.dart';
import '../screens/map_screen.dart';
import '../screens/preference_screen.dart';

enum CompareOp { greater, equal, less }

class _Filter {
  String? type; // '매매', '월세', '전세'
  CompareOp? floorOp;
  int? floorValue;
  CompareOp? areaOp;
  double? areaValue;
  CompareOp? priceOp;
  int? priceValue;

  _Filter();
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _Filter _filter = _Filter();

  // 예시 데이터 (실제 데이터는 서버에서 받아오면 됨)
  final List<Property> properties = [
    Property(
      image: 'lib/assets/default_image.png',
      address: '서울시 강남구 역삼동 123-45',
      type: '아파트',
      floor: 10,
      area: 84.5,
      price: 1000000000,
      options: '풀옵션',
      contact: '010-1234-5678',
      tags: ['역세권', '주차공간넓음'],
      isFavorite: false,
    ),
    // ... 추가 데이터
  ];

  List<Property> get filteredProperties {
    Iterable<Property> result = properties;
    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) {
        final addressMatch = p.address.toLowerCase().contains(query);
        final tagMatch = p.tags.any((tag) => tag.toLowerCase().contains(query));
        return addressMatch || tagMatch;
      });
    }
    // 종류 필터
    if (_filter.type != null && _filter.type!.isNotEmpty) {
      result = result.where((p) => p.type == _filter.type);
    }
    // 층수 필터
    if (_filter.floorOp != null && _filter.floorValue != null) {
      switch (_filter.floorOp) {
        case CompareOp.greater:
          result = result.where((p) => p.floor > _filter.floorValue!);
          break;
        case CompareOp.equal:
          result = result.where((p) => p.floor == _filter.floorValue!);
          break;
        case CompareOp.less:
          result = result.where((p) => p.floor < _filter.floorValue!);
          break;
        default:
      }
    }
    // 평수 필터
    if (_filter.areaOp != null && _filter.areaValue != null) {
      switch (_filter.areaOp) {
        case CompareOp.greater:
          result = result.where((p) => p.area > _filter.areaValue!);
          break;
        case CompareOp.equal:
          result = result.where((p) => p.area == _filter.areaValue!);
          break;
        case CompareOp.less:
          result = result.where((p) => p.area < _filter.areaValue!);
          break;
        default:
      }
    }
    // 가격 필터
    if (_filter.priceOp != null && _filter.priceValue != null) {
      switch (_filter.priceOp) {
        case CompareOp.greater:
          result = result.where((p) => p.price > _filter.priceValue!);
          break;
        case CompareOp.equal:
          result = result.where((p) => p.price == _filter.priceValue!);
          break;
        case CompareOp.less:
          result = result.where((p) => p.price < _filter.priceValue!);
          break;
        default:
      }
    }
    return result.toList();
  }

  void _openFilterSheet() {
    String? selectedType = _filter.type;
    CompareOp? floorOp = _filter.floorOp;
    int? floorValue = _filter.floorValue;
    CompareOp? areaOp = _filter.areaOp;
    double? areaValue = _filter.areaValue;
    CompareOp? priceOp = _filter.priceOp;
    int? priceValue = _filter.priceValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('종류', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedType,
                  hint: const Text('선택'),
                  isExpanded: true,
                  items:
                      ['매매', '월세', '전세']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('층수', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    DropdownButton<CompareOp>(
                      value: floorOp,
                      hint: const Text('비교'),
                      items: [
                        DropdownMenuItem(
                          value: CompareOp.greater,
                          child: Text('>'),
                        ),
                        DropdownMenuItem(
                          value: CompareOp.equal,
                          child: Text('='),
                        ),
                        DropdownMenuItem(
                          value: CompareOp.less,
                          child: Text('<'),
                        ),
                      ],
                      onChanged: (op) {
                        setState(() {
                          floorOp = op;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '숫자'),
                        onChanged: (v) {
                          setState(() {
                            floorValue = int.tryParse(v);
                          });
                        },
                        controller: TextEditingController(
                          text: floorValue?.toString() ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('평수', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    DropdownButton<CompareOp>(
                      value: areaOp,
                      hint: const Text('비교'),
                      items: [
                        DropdownMenuItem(
                          value: CompareOp.greater,
                          child: Text('>'),
                        ),
                        DropdownMenuItem(
                          value: CompareOp.equal,
                          child: Text('='),
                        ),
                        DropdownMenuItem(
                          value: CompareOp.less,
                          child: Text('<'),
                        ),
                      ],
                      onChanged: (op) {
                        setState(() {
                          areaOp = op;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '숫자'),
                        onChanged: (v) {
                          setState(() {
                            areaValue = double.tryParse(v);
                          });
                        },
                        controller: TextEditingController(
                          text: areaValue?.toString() ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('가격', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    DropdownButton<CompareOp>(
                      value: priceOp,
                      hint: const Text('비교'),
                      items: [
                        DropdownMenuItem(
                          value: CompareOp.greater,
                          child: Text('>'),
                        ),
                        DropdownMenuItem(
                          value: CompareOp.equal,
                          child: Text('='),
                        ),
                        DropdownMenuItem(
                          value: CompareOp.less,
                          child: Text('<'),
                        ),
                      ],
                      onChanged: (op) {
                        setState(() {
                          priceOp = op;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '숫자'),
                        onChanged: (v) {
                          setState(() {
                            priceValue = int.tryParse(v);
                          });
                        },
                        controller: TextEditingController(
                          text: priceValue?.toString() ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filter.type = selectedType;
                          _filter.floorOp = floorOp;
                          _filter.floorValue = floorValue;
                          _filter.areaOp = areaOp;
                          _filter.areaValue = areaValue;
                          _filter.priceOp = priceOp;
                          _filter.priceValue = priceValue;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('적용'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite(Property property) {
    setState(() {
      final index = properties.indexOf(property);
      if (index != -1) {
        // 불변 객체이므로 복사본 생성
        final updated = Property(
          image: property.image,
          address: property.address,
          type: property.type,
          floor: property.floor,
          area: property.area,
          price: property.price,
          options: property.options,
          contact: property.contact,
          tags: property.tags,
          isFavorite: !property.isFavorite,
        );
        properties[index] = updated;
        // 즐겨찾기 우선 정렬
        properties.sort((a, b) {
          if (a.isFavorite == b.isFavorite) return 0;
          return a.isFavorite ? -1 : 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 검색 바
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
                          IconButton(
                            icon: const Icon(
                              Icons.filter_alt_outlined,
                              size: 20,
                            ),
                            onPressed: _openFilterSheet,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: '검색',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  final property = filteredProperties[index];
                  return _PropertyCard(
                    property: property,
                    onToggleFavorite: () => _toggleFavorite(property),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Preference',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // 이미 Home이므로 아무것도 안 해도 됨
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PreferenceScreen()),
            );
          }
        },
      ),
      // Add 버튼 (FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE3DFDC),
        onPressed: () {
          // TODO: Add 화면으로 이동
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// 매물 카드 위젯
class _PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onToggleFavorite;

  const _PropertyCard({
    required this.property,
    required this.onToggleFavorite,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => InfoSheet(property: property),
        );
      },
      child: Card(
        color: const Color(0xFFFCFCFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  property.image.isNotEmpty
                      ? property.image
                      : 'lib/assets/default_image.png',
                  width: 129,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              // 태그
              Row(
                children:
                    property.tags
                        .map(
                          (tag) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F5FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              // 즐겨찾기 버튼
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    property.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: property.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: onToggleFavorite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

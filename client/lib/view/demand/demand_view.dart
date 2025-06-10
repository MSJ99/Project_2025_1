import 'package:flutter/material.dart';
import '../../widgets/demand_card.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/demand_viewmodel.dart';
import 'add_view.dart';
import '../../view/map/map_view.dart';
import '../../data/models/property.dart';

class DemandView extends StatefulWidget {
  const DemandView({Key? key}) : super(key: key);

  @override
  State<DemandView> createState() => _DemandViewState();
}

class _DemandViewState extends State<DemandView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Property와 동일한 구조의 필터 클래스(확장 가능)
  // class _Filter { ... } // 필요시 추가

  void _openFilterSheet() {
    // TODO: Property와 동일한 필터시트 구현(확장 가능)
    showModalBottomSheet(
      context: context,
      builder:
          (context) => const SizedBox(
            height: 200,
            child: Center(child: Text('필터 기능 준비중')), // 임시
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandViewModel>(context, listen: false).fetchDemands();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DemandViewModel>(context);
    final filteredDemands = getFilteredDemands(viewModel.demands);

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
            const SizedBox(height: 8),
            Expanded(
              child:
                  viewModel.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredDemands.length,
                        itemBuilder: (context, index) {
                          final demand = filteredDemands[index];
                          final matchedCount =
                              viewModel.matchedPropertyCountByDemandId[demand
                                      .id ??
                                  ''] ??
                              0;
                          return DemandCard(
                            demand: demand,
                            matchedCount: matchedCount,
                            onMapButtonPressed:
                                matchedCount > 0
                                    ? () async {
                                      final matchRepo =
                                          Provider.of<DemandViewModel>(
                                            context,
                                            listen: false,
                                          ).matchRepository;
                                      // 매칭 결과 Map 구조로 받음
                                      final result = await matchRepo
                                          .fetchMatchedPropertiesForDemand(
                                            demand.id!,
                                          );
                                      final propertyIds =
                                          (result['matched'] as List<Property>?)
                                              ?.map((p) => p.id ?? '')
                                              .where((id) => id.isNotEmpty)
                                              .toList() ??
                                          [];
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => MapView(
                                                matchedPropertyIds: propertyIds,
                                                matchedCustomerName:
                                                    demand.customerName ?? '',
                                              ),
                                        ),
                                      );
                                    }
                                    : null,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DemandAddView()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List getFilteredDemands(List demands) {
    if (_searchQuery.isEmpty) return demands;
    final query = _searchQuery.toLowerCase();
    return demands.where((d) {
      final nameMatch = (d.customerName ?? '').toLowerCase().contains(query);
      return nameMatch;
    }).toList();
  }
}

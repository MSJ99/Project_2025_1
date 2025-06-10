import 'package:flutter/material.dart';
import '../data/models/demand.dart';
import '../view/demand/edit_view.dart';
import 'package:provider/provider.dart';
import '../viewmodel/demand_viewmodel.dart';
import '../view/map/map_view.dart';
import '../viewmodel/property_viewmodel.dart';

class InfoSheet extends StatelessWidget {
  final Demand demand;
  final bool fromMapView;
  const InfoSheet({required this.demand, this.fromMapView = false, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    demand.customerName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('거래종류: ${demand.tradeType}'),
                  Text('건물 유형: ${demand.propertyType ?? ''}'),
                  Text('보증금: ${demand.price ?? ''}원 이하'),
                  if (demand.monthlyRent != null && demand.monthlyRent != 0)
                    Text('월세: ${demand.monthlyRent}원 이하'),
                  Text(
                    '층수: ${demand.floor != null && demand.floor!.isNotEmpty ? demand.floor : '상관없음'}',
                  ),
                  Text(
                    '방 개수: ${demand.roomCount != null ? '${demand.roomCount}개 이상' : '상관없음'}',
                  ),
                  Text('평수: ${demand.area != null ? demand.area : '상관없음'}'),
                  Text(
                    '입주 가능일: '
                    '${demand.moveInDate != null ? demand.moveInDate!.toIso8601String().split('T').first + ' 이전' : '상관없음'}',
                  ),
                  Text('연락처: ${demand.contact}'),
                  const SizedBox(height: 8),
                  if (demand.options != null && demand.options!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children:
                          demand.options!
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => DemandEditView(demand: demand),
                            ),
                          );
                        },
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () async {
                          print('[만족하는 매물 찾기] demand.id: \'${demand.id}\'');
                          final viewModel = Provider.of<DemandViewModel>(
                            context,
                            listen: false,
                          );
                          final matchRepo = viewModel.matchRepository;
                          final result = await matchRepo
                              .fetchMatchedPropertiesForDemand(demand.id!);
                          print('[만족하는 매물 찾기] 서버 응답: \$result');
                          final matched =
                              result['matched'] as List<dynamic>? ?? [];
                          print(
                            '[만족하는 매물 찾기] matched property ids: '
                            '${matched.map((p) => p.id?.toString() ?? '').where((id) => id.isNotEmpty).toList()}',
                          );
                          print('[만족하는 매물 찾기] 매칭 개수: \'${matched.length}\'');
                          final propertyIds =
                              matched
                                  .map((p) => p.id?.toString() ?? '')
                                  .where((id) => id.isNotEmpty)
                                  .toList();
                          viewModel.matchedPropertyCountByDemandId[demand.id!] =
                              matched.length;
                          viewModel.notifyListeners();
                          // Property별 매칭 개수도 새로고침 (지도 마커 텍스트 반영)
                          final propertyViewModel =
                              Provider.of<PropertyViewModel>(
                                context,
                                listen: false,
                              );
                          await propertyViewModel.fetchPropertiesAndMatches(
                            propertyViewModel.matchRepository,
                          );
                        },
                        child: const Text('만족하는 매물 찾기'),
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

class DemandCard extends StatelessWidget {
  final Demand demand;
  final int matchedCount;
  final VoidCallback? onMapButtonPressed;
  const DemandCard({
    required this.demand,
    this.matchedCount = 0,
    this.onMapButtonPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEAECF0), width: 2),
      ),
      child: ListTile(
        title: Text(
          demand.customerName ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => InfoSheet(demand: demand),
          );
          if (result == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('요구사항이 삭제되었습니다.')));
          }
        },
      ),
    );
  }
}

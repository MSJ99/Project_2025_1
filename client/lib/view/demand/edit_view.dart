import 'package:flutter/material.dart';
import '../../data/models/demand.dart';
import '../../viewmodel/demand_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DemandEditView extends StatefulWidget {
  final Demand demand;
  const DemandEditView({Key? key, required this.demand}) : super(key: key);

  @override
  State<DemandEditView> createState() => _DemandEditViewState();
}

class _DemandEditViewState extends State<DemandEditView> {
  late TextEditingController _customerNameController;
  late TextEditingController _tradeTypeController;
  late TextEditingController _priceController;
  late TextEditingController _monthlyRentController;
  late TextEditingController _contactController;
  late TextEditingController _optionsController;
  late TextEditingController _floorController;
  late TextEditingController _roomCountController;
  late TextEditingController _areaController;
  late TextEditingController _propertyTypeController;
  late TextEditingController _moveInDateController;

  String _tradeType = '';

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.demand.customerName ?? '',
    );
    _propertyTypeController = TextEditingController(
      text: widget.demand.propertyType ?? '',
    );
    _tradeTypeController = TextEditingController(text: widget.demand.tradeType);
    _tradeType = _tradeTypeController.text;
    _priceController = TextEditingController(
      text: widget.demand.price.toString(),
    );
    _monthlyRentController = TextEditingController(
      text: widget.demand.monthlyRent?.toString() ?? '',
    );
    _floorController = TextEditingController(text: widget.demand.floor ?? '');
    _roomCountController = TextEditingController(
      text: widget.demand.roomCount?.toString() ?? '',
    );
    _areaController = TextEditingController(
      text: widget.demand.area?.toString() ?? '',
    );
    _contactController = TextEditingController(text: widget.demand.contact);
    _optionsController = TextEditingController(
      text: widget.demand.options?.join(',') ?? '',
    );
    _moveInDateController = TextEditingController(
      text:
          widget.demand.moveInDate != null
              ? widget.demand.moveInDate!.toIso8601String().split('T').first
              : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요구사항 수정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildTextField(_customerNameController, '고객이름'),
            const SizedBox(height: 16),
            _buildTextField(_propertyTypeController, '건물 유형'),
            const SizedBox(height: 16),
            _buildTextField(
              _tradeTypeController,
              '거래종류',
              onChanged: (value) {
                setState(() {
                  _tradeType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _priceController,
                    '보증금',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _monthlyRentController,
                    keyboardType: TextInputType.number,
                    enabled: _tradeType.trim() == '월세',
                    decoration: InputDecoration(
                      labelText: '월세',
                      hintText: _tradeType.trim() == '월세' ? null : '월세 거래에만 입력',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _floorController,
              '층수',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _roomCountController,
              '방 개수',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _areaController,
              '평수',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _contactController,
              '연락처',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _moveInDateController,
              '입주 가능일 (YYYY-MM-DD)',
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            _buildTextField(_optionsController, '옵션 (쉼표로 구분)'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2c2c2c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        print('EditView demand.id: ${widget.demand.id}');
                        if (widget.demand.id == null ||
                            widget.demand.id!.length != 24) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('잘못된 Demand ID입니다.')),
                          );
                          return;
                        }
                        final updatedDemand = Demand(
                          tradeType:
                              _tradeTypeController.text.isNotEmpty
                                  ? _tradeTypeController.text
                                  : widget.demand.tradeType,
                          price:
                              int.tryParse(_priceController.text) ??
                              widget.demand.price,
                          contact:
                              _contactController.text.isNotEmpty
                                  ? _contactController.text
                                  : widget.demand.contact,
                          customerName:
                              _customerNameController.text.isNotEmpty
                                  ? _customerNameController.text
                                  : widget.demand.customerName,
                          floor:
                              _floorController.text.isNotEmpty
                                  ? _floorController.text
                                  : widget.demand.floor,
                          area:
                              _areaController.text.isNotEmpty
                                  ? double.tryParse(_areaController.text)
                                  : widget.demand.area,
                          options:
                              _optionsController.text.isNotEmpty
                                  ? _optionsController.text
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList()
                                  : widget.demand.options,
                          roomCount:
                              _roomCountController.text.isNotEmpty
                                  ? int.tryParse(_roomCountController.text)
                                  : widget.demand.roomCount,
                          propertyType:
                              _propertyTypeController.text.isNotEmpty
                                  ? _propertyTypeController.text
                                  : widget.demand.propertyType,
                          moveInDate:
                              _moveInDateController.text.isNotEmpty
                                  ? DateTime.tryParse(
                                    _moveInDateController.text,
                                  )
                                  : widget.demand.moveInDate,
                          monthlyRent:
                              _monthlyRentController.text.isNotEmpty
                                  ? int.tryParse(_monthlyRentController.text)
                                  : widget.demand.monthlyRent,
                        );
                        await Provider.of<DemandViewModel>(
                          context,
                          listen: false,
                        ).updateDemand(widget.demand.id!, updatedDemand);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('요구사항이 수정되었습니다.')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('삭제 확인'),
                                content: const Text('정말로 이 요구사항을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('삭제'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await Provider.of<DemandViewModel>(
                            context,
                            listen: false,
                          ).deleteDemand(widget.demand.id!);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('요구사항이 삭제되었습니다.')),
                          );
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
      ),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _propertyTypeController.dispose();
    _tradeTypeController.dispose();
    _priceController.dispose();
    _monthlyRentController.dispose();
    _floorController.dispose();
    _roomCountController.dispose();
    _areaController.dispose();
    _contactController.dispose();
    _optionsController.dispose();
    _moveInDateController.dispose();
    super.dispose();
  }
}

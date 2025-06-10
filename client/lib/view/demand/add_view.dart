import 'package:flutter/material.dart';
import '../../data/models/demand.dart';
import '../../viewmodel/demand_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DemandAddView extends StatefulWidget {
  const DemandAddView({Key? key}) : super(key: key);

  @override
  State<DemandAddView> createState() => _DemandAddViewState();
}

class _DemandAddViewState extends State<DemandAddView> {
  final _customerNameController = TextEditingController();
  final _tradeTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _contactController = TextEditingController();
  final _optionsController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomCountController = TextEditingController();
  final _areaController = TextEditingController();
  final _propertyTypeController = TextEditingController();
  final _moveInDateController = TextEditingController();
  final _tagsController = TextEditingController();

  String _tradeType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요구사항 등록'),
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
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2c2c2c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final demand = Demand(
                    tradeType: _tradeTypeController.text,
                    price: int.tryParse(_priceController.text) ?? 0,
                    contact: _contactController.text,
                    customerName:
                        _customerNameController.text.isNotEmpty
                            ? _customerNameController.text
                            : null,
                    floor:
                        _floorController.text.isNotEmpty
                            ? _floorController.text
                            : null,
                    area:
                        _areaController.text.isNotEmpty
                            ? double.tryParse(_areaController.text)
                            : null,
                    options:
                        _optionsController.text.isNotEmpty
                            ? _optionsController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList()
                            : null,
                    roomCount:
                        _roomCountController.text.isNotEmpty
                            ? int.tryParse(_roomCountController.text)
                            : null,
                    propertyType:
                        _propertyTypeController.text.isNotEmpty
                            ? _propertyTypeController.text
                            : null,
                    moveInDate:
                        _moveInDateController.text.isNotEmpty
                            ? DateTime.tryParse(_moveInDateController.text)
                            : null,
                    monthlyRent:
                        _monthlyRentController.text.isNotEmpty
                            ? int.tryParse(_monthlyRentController.text)
                            : null,
                  );
                  await Provider.of<DemandViewModel>(
                    context,
                    listen: false,
                  ).addDemand(demand);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('요구사항이 등록되었습니다.')),
                  );
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../data/models/property.dart';
import '../../viewmodel/property_viewmodel.dart';

class PropertyAddView extends StatefulWidget {
  const PropertyAddView({Key? key}) : super(key: key);

  @override
  State<PropertyAddView> createState() => _PropertyAddViewState();
}

class _PropertyAddViewState extends State<PropertyAddView> {
  XFile? _image;
  final picker = ImagePicker();

  final _addressController = TextEditingController();
  final _propertyTypeController = TextEditingController();
  final _tradeTypeController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomCountController = TextEditingController();
  final _areaController = TextEditingController();
  final _priceController = TextEditingController();
  final _optionsController = TextEditingController();
  final _contactController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _moveInDateController = TextEditingController();

  String _tradeType = '';

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매물 등록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 첨부 버튼
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child:
                    _image == null
                        ? Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_image!.path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(_addressController, '주소'),
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
                  final property = Property(
                    image: '', // 서버에서 처리
                    address: _addressController.text,
                    propertyType: _propertyTypeController.text,
                    tradeType: _tradeTypeController.text,
                    floor: _floorController.text,
                    area: double.tryParse(_areaController.text) ?? 0.0,
                    price: int.tryParse(_priceController.text) ?? 0,
                    options:
                        _optionsController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                    roomCount: int.tryParse(_roomCountController.text) ?? 0,
                    moveInDate:
                        _moveInDateController.text.isNotEmpty
                            ? DateTime.tryParse(_moveInDateController.text) ??
                                DateTime(2025)
                            : DateTime(2025),
                    monthlyRent: int.tryParse(_monthlyRentController.text),
                    contact: _contactController.text,
                  );
                  final viewModel = Provider.of<PropertyViewModel>(
                    context,
                    listen: false,
                  );
                  final result = await viewModel.addProperty(
                    property,
                    imagePath: _image?.path,
                  );
                  if (!mounted) return;
                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('매물이 등록되었습니다.')),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('등록 실패')));
                  }
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
}

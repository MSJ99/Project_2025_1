import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../data/models/property.dart';
import '../../viewmodel/property_viewmodel.dart';
import 'dart:io';

class EditView extends StatefulWidget {
  final Map<String, dynamic> property;
  const EditView({Key? key, required this.property}) : super(key: key);

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  XFile? _image;
  final picker = ImagePicker();

  late final TextEditingController _addressController;
  late final TextEditingController _propertyTypeController;
  late final TextEditingController _tradeTypeController;
  late final TextEditingController _priceController;
  late final TextEditingController _monthlyRentController;
  late final TextEditingController _contactController;
  late final TextEditingController _optionsController;
  late final TextEditingController _tagsController;
  late final TextEditingController _floorController;
  late final TextEditingController _roomCountController;
  late final TextEditingController _areaController;
  late final TextEditingController _moveInDateController;
  late final String? _id;

  final backendIp = dotenv.env['BACKEND_IP'] ?? 'localhost';
  final backendPort = dotenv.env['BACKEND_PORT'] ?? '8080';

  String _tradeType = '';

  @override
  void initState() {
    super.initState();
    _id = widget.property['id']?.toString();
    _addressController = TextEditingController(
      text: widget.property['address'] ?? '',
    );
    _propertyTypeController = TextEditingController(
      text: widget.property['propertyType'] ?? '',
    );
    _tradeTypeController = TextEditingController(
      text: widget.property['tradeType'] ?? widget.property['trade_type'] ?? '',
    );
    _tradeType = _tradeTypeController.text;
    _priceController = TextEditingController(
      text: widget.property['price']?.toString() ?? '',
    );
    _monthlyRentController = TextEditingController(
      text: widget.property['monthlyRent']?.toString() ?? '',
    );
    _floorController = TextEditingController(
      text: widget.property['floor']?.toString() ?? '',
    );
    _roomCountController = TextEditingController(
      text: widget.property['roomCount']?.toString() ?? '',
    );
    _areaController = TextEditingController(
      text: widget.property['area']?.toString() ?? '',
    );
    _contactController = TextEditingController(
      text: widget.property['contact'] ?? '',
    );
    _optionsController = TextEditingController(
      text:
          widget.property['options'] is List
              ? (widget.property['options'] as List).join(',')
              : (widget.property['options'] ?? ''),
    );
    _tagsController = TextEditingController(
      text: widget.property['tags'] ?? '',
    );
    _moveInDateController = TextEditingController(
      text:
          widget.property['moveInDate'] != null
              ? (widget.property['moveInDate'] is DateTime
                  ? (widget.property['moveInDate'] as DateTime)
                      .toIso8601String()
                      .split('T')
                      .first
                  : widget.property['moveInDate'].toString().split('T').first)
              : '',
    );
  }

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
    _tagsController.dispose();
    _moveInDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매물 수정'),
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
                    _image != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_image!.path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Container(
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
                        final id = _id;
                        if (id == null || id.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물 ID가 없습니다.')),
                          );
                          return;
                        }
                        final property = Property(
                          image: '', // 서버에서 처리
                          address:
                              _addressController.text.isNotEmpty
                                  ? _addressController.text
                                  : widget.property['address'] ?? '',
                          propertyType:
                              _propertyTypeController.text.isNotEmpty
                                  ? _propertyTypeController.text
                                  : widget.property['propertyType'] ?? '',
                          tradeType:
                              _tradeTypeController.text.isNotEmpty
                                  ? _tradeTypeController.text
                                  : widget.property['tradeType'] ??
                                      widget.property['trade_type'] ??
                                      '',
                          floor:
                              _floorController.text.isNotEmpty
                                  ? _floorController.text
                                  : widget.property['floor'] ?? '',
                          area:
                              double.tryParse(_areaController.text) ??
                              (widget.property['area'] is double
                                  ? widget.property['area']
                                  : double.tryParse(
                                        widget.property['area']?.toString() ??
                                            '0',
                                      ) ??
                                      0.0),
                          price:
                              int.tryParse(_priceController.text) ??
                              (widget.property['price'] is int
                                  ? widget.property['price']
                                  : int.tryParse(
                                        widget.property['price']?.toString() ??
                                            '0',
                                      ) ??
                                      0),
                          options:
                              _optionsController.text.isNotEmpty
                                  ? _optionsController.text
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList()
                                  : (widget.property['options'] is List
                                      ? List<String>.from(
                                        widget.property['options'],
                                      )
                                      : []),
                          roomCount:
                              _roomCountController.text.isNotEmpty
                                  ? int.tryParse(_roomCountController.text)
                                  : (widget.property['roomCount'] is int
                                      ? widget.property['roomCount']
                                      : int.tryParse(
                                            widget.property['roomCount']
                                                    ?.toString() ??
                                                '0',
                                          ) ??
                                          0),
                          moveInDate:
                              _moveInDateController.text.isNotEmpty
                                  ? DateTime.tryParse(
                                        _moveInDateController.text,
                                      ) ??
                                      DateTime(2025)
                                  : (widget.property['moveInDate'] is DateTime
                                      ? widget.property['moveInDate']
                                      : (widget.property['moveInDate'] != null
                                          ? DateTime.tryParse(
                                                widget.property['moveInDate']
                                                    .toString(),
                                              ) ??
                                              DateTime(2025)
                                          : DateTime(2025))),
                          monthlyRent:
                              _monthlyRentController.text.isNotEmpty
                                  ? int.tryParse(_monthlyRentController.text)
                                  : (widget.property['monthlyRent'] is int
                                      ? widget.property['monthlyRent']
                                      : int.tryParse(
                                            widget.property['monthlyRent']
                                                    ?.toString() ??
                                                '',
                                          ) ??
                                          null),
                          contact:
                              _contactController.text.isNotEmpty
                                  ? _contactController.text
                                  : widget.property['contact'] ?? '',
                        );
                        final viewModel = Provider.of<PropertyViewModel>(
                          context,
                          listen: false,
                        );
                        final result = await viewModel.updateProperty(
                          id,
                          property,
                          imagePath: _image?.path,
                        );
                        if (!mounted) return;
                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물이 수정되었습니다.')),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('수정 실패')),
                          );
                        }
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
                        final id =
                            widget.property['id'] ?? widget.property['_id'];
                        print('Delete property id: $id');
                        if (id == null || id.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물 ID가 없습니다.')),
                          );
                          return;
                        }
                        final url = Uri.parse(
                          'http://$backendIp:$backendPort/api/properties/$id',
                        );
                        final response = await http.delete(url);
                        if (response.statusCode == 200) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물이 삭제되었습니다.')),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('삭제 실패: \\${response.body}'),
                            ),
                          );
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
}

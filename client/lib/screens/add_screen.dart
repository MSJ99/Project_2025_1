import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  XFile? _image;
  final picker = ImagePicker();

  final _addressController = TextEditingController();
  final _typeController = TextEditingController();
  final _floorController = TextEditingController();
  final _areaController = TextEditingController();
  final _priceController = TextEditingController();
  final _optionsController = TextEditingController();
  final _contactController = TextEditingController();
  final _tagsController = TextEditingController();

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
    _typeController.dispose();
    _floorController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _optionsController.dispose();
    _contactController.dispose();
    _tagsController.dispose();
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Undo
            },
            child: const Text('Undo', style: TextStyle(color: Colors.black)),
          ),
        ],
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
            _buildTextField(_typeController, '종류'),
            const SizedBox(height: 16),
            _buildTextField(
              _floorController,
              '층수',
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
              _priceController,
              '가격',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(_optionsController, '옵션'),
            const SizedBox(height: 16),
            _buildTextField(
              _contactController,
              '연락처',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(_tagsController, '태그 (쉼표로 구분)'),
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
                onPressed: () {
                  // TODO: 서버로 데이터 전송 및 등록 처리
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
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
                onPressed: () async {
                  final url = Uri.parse('http://localhost:8080/api/properties');
                  var request = http.MultipartRequest('POST', url);

                  // 텍스트 필드 추가
                  request.fields['address'] = _addressController.text;
                  request.fields['type'] = _typeController.text;
                  request.fields['floor'] = _floorController.text;
                  request.fields['area'] = _areaController.text;
                  request.fields['price'] = _priceController.text;
                  request.fields['options'] = _optionsController.text;
                  request.fields['contact'] = _contactController.text;
                  request.fields['tags'] = _tagsController.text; // 쉼표로 구분된 문자열

                  // 이미지 파일 추가 (선택된 경우)
                  if (_image != null) {
                    request.files.add(
                      await http.MultipartFile.fromPath('image', _image!.path),
                    );
                  } else {
                    // 이미지가 선택되지 않은 경우, 기본 이미지 경로를 필드로 추가
                    request.fields['image'] = 'lib/assets/default_image.png';
                  }

                  // 요청 보내기
                  var response = await request.send();

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('매물이 등록되었습니다.')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('등록 실패: ${response.reasonPhrase}'),
                      ),
                    );
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

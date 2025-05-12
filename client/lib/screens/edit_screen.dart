import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const EditScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  XFile? _image;
  final picker = ImagePicker();

  late final TextEditingController _addressController;
  late final TextEditingController _typeController;
  late final TextEditingController _floorController;
  late final TextEditingController _areaController;
  late final TextEditingController _priceController;
  late final TextEditingController _optionsController;
  late final TextEditingController _contactController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.property['address'] ?? '',
    );
    _typeController = TextEditingController(
      text: widget.property['type'] ?? '',
    );
    _floorController = TextEditingController(
      text: widget.property['floor']?.toString() ?? '',
    );
    _areaController = TextEditingController(
      text: widget.property['area']?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.property['price']?.toString() ?? '',
    );
    _optionsController = TextEditingController(
      text: widget.property['options'] ?? '',
    );
    _contactController = TextEditingController(
      text: widget.property['contact'] ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.property['tags'] ?? '',
    );
    if (widget.property['imagePath'] != null &&
        widget.property['imagePath'].toString().isNotEmpty) {
      _image = XFile(widget.property['imagePath']);
    }
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'lib/assets/default_image.png',
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
                        final id = widget.property['_id'];
                        if (id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물 ID가 없습니다.')),
                          );
                          return;
                        }

                        final url = Uri.parse(
                          'http://localhost:8080/api/properties/$id',
                        );
                        var request = http.MultipartRequest('PATCH', url);

                        // 텍스트 필드 추가
                        request.fields['address'] = _addressController.text;
                        request.fields['type'] = _typeController.text;
                        request.fields['floor'] = _floorController.text;
                        request.fields['area'] = _areaController.text;
                        request.fields['price'] = _priceController.text;
                        request.fields['options'] = _optionsController.text;
                        request.fields['contact'] = _contactController.text;
                        request.fields['tags'] =
                            _tagsController.text; // 쉼표로 구분된 문자열

                        // 이미지 파일 추가 (선택된 경우)
                        if (_image != null) {
                          request.files.add(
                            await http.MultipartFile.fromPath(
                              'image',
                              _image!.path,
                            ),
                          );
                        } else if (widget.property['imagePath'] != null &&
                            widget.property['imagePath']
                                .toString()
                                .isNotEmpty) {
                          // 기존 이미지 경로를 그대로 전달
                          request.fields['image'] =
                              widget.property['imagePath'];
                        }

                        // 요청 보내기
                        var response = await request.send();

                        if (response.statusCode == 200) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물이 수정되었습니다.')),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('수정 실패: ${response.reasonPhrase}'),
                            ),
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
                        final id = widget.property['_id'];
                        if (id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물 ID가 없습니다.')),
                          );
                          return;
                        }
                        final url = Uri.parse(
                          'http://localhost:8080/api/properties/$id',
                        );
                        final response = await http.delete(url);
                        if (response.statusCode == 200) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('매물이 삭제되었습니다.')),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: ${response.body}')),
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

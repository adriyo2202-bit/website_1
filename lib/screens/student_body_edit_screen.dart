import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'dart:io';
import '../services/data_service.dart';

class StudentBodyEditScreen extends StatefulWidget {
  final String dataKey;
  final Map<String, dynamic>? existingItem;
  final int? itemIndex;

  const StudentBodyEditScreen({
    Key? key,
    required this.dataKey,
    this.existingItem,
    this.itemIndex,
  }) : super(key: key);

  @override
  State<StudentBodyEditScreen> createState() => _StudentBodyEditScreenState();
}

class _StudentBodyEditScreenState extends State<StudentBodyEditScreen> with SingleTickerProviderStateMixin {
  String? _localImagePath;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _initializeData();
  }
  
  void _initializeData() {
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _nameController.text = item['name'] ?? '';
      _positionController.text = item['position'] ?? '';
      _deptController.text = item['department'] ?? '';
      _contactController.text = item['contactNum'] ?? '';
      _emailController.text = item['contactEmail'] ?? '';
      
      final images = item['image'];
      if (images != null) {
        if (images is String && images.isNotEmpty) {
          _localImagePath = images;
        } else if (images is List && images.isNotEmpty) {
          _localImagePath = images.first.toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _nameController.dispose();
    _positionController.dispose();
    _deptController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      final File sourceFile = File(pickedFile.path);
      final String newLocalPath = await DataService.saveImageForCategory(widget.dataKey, sourceFile);
      setState(() {
        _localImagePath = newLocalPath;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });
    
    final data = await DataService.loadData();
    final currentList = data[widget.dataKey] as List? ?? [];
    
    final newItem = {
      "id": widget.existingItem?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      "name": _nameController.text.trim(),
      "image": _localImagePath ?? '', // Schema says string
      "position": _positionController.text.trim(),
      "department": _deptController.text.trim(),
      "contactNum": _contactController.text.trim(),
      "contactEmail": _emailController.text.trim(),
    };
    
    if (widget.itemIndex != null && widget.itemIndex! < currentList.length) {
      currentList[widget.itemIndex!] = newItem;
    } else {
      currentList.add(newItem);
    }
    
    data[widget.dataKey] = currentList;
    await DataService.saveData(data);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }
  
  Widget _buildGradientTextField({
    required String hint, 
    required TextEditingController controller, 
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6ED), Color(0xFFFBE4EA)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(color: const Color(0xFFFFFDF4)), // Base color
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgAnimController.value * 2 * math.pi) * size.width * 0.4 -
                        300,
                    top: size.height * 0.5 +
                        math.sin(_bgAnimController.value * 2 * math.pi) * size.height * 0.4 -
                        300,
                    child: Container(
                      width: 600,
                      height: 600,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFD4EAD1).withOpacity(0.4),
                            const Color(0xFFD4EAD1).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgAnimController.value * 2 * math.pi + math.pi) * size.width * 0.3 -
                        250,
                    top: size.height * 0.5 +
                        math.sin(_bgAnimController.value * 2 * math.pi + math.pi / 2) * size.height * 0.3 -
                        250,
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFE0CBE6).withOpacity(0.4),
                            const Color(0xFFE0CBE6).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker Card
                  GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child: Container(
                        width: size.width * 0.7,
                        height: size.width * 0.7,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF4DEFF), Color(0xFFE6EDFF)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            )
                          ]
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _localImagePath != null && _localImagePath!.isNotEmpty
                            ? Image.file(File(_localImagePath!), fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("🧑‍🎓", style: TextStyle(fontSize: 50)),
                                  const SizedBox(height: 12),
                                  const Text("Add Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel("Name"),
                  _buildGradientTextField(hint: "Name of the faculty", controller: _nameController),
                  
                  _buildLabel("Contact"),
                  _buildGradientTextField(hint: "Contact Number", controller: _contactController, keyboardType: TextInputType.phone),
                  
                  _buildLabel("Email"),
                  _buildGradientTextField(hint: "Contact Email", controller: _emailController, keyboardType: TextInputType.emailAddress),
                  
                  _buildLabel("Department"),
                  _buildGradientTextField(hint: "Department name", controller: _deptController),
                  
                  _buildLabel("Position"),
                  _buildGradientTextField(hint: "Position", controller: _positionController),
                  
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4EAD1), Color(0xFFFBE4EA)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black87),
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("Save", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

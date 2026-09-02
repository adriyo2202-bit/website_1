import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'dart:io';
import '../services/data_service.dart';

class WardenEditScreen extends StatefulWidget {
  final String dataKey;
  final Map<String, dynamic>? existingItem;
  final int? itemIndex;

  const WardenEditScreen({
    Key? key,
    required this.dataKey,
    this.existingItem,
    this.itemIndex,
  }) : super(key: key);

  @override
  State<WardenEditScreen> createState() => _WardenEditScreenState();
}

class _WardenEditScreenState extends State<WardenEditScreen> with SingleTickerProviderStateMixin {
  String? _localImagePath;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  
  List<TextEditingController> _contactControllers = [TextEditingController()];
  List<TextEditingController> _emailControllers = [TextEditingController()];
  
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
      _departmentController.text = item['position'] ?? '';
      
      if (item['images'] != null && (item['images'] as List).isNotEmpty) {
        _localImagePath = (item['images'] as List).first.toString();
      }
      
      void initList(String key, List<TextEditingController> controllers) {
        if (item[key] != null) {
          final list = item[key] as List;
          if (list.isNotEmpty) {
            controllers.clear();
            controllers.addAll(list.map((c) => TextEditingController(text: c.toString())));
          }
        }
      }
      
      initList('contacts', _contactControllers);
      initList('emails', _emailControllers);
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    for (var c in _contactControllers) { c.dispose(); }
    for (var c in _emailControllers) { c.dispose(); }
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
    
    List<String> getValues(List<TextEditingController> controllers) {
      return controllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    }
    
    final newItem = {
      "id": widget.existingItem?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      "name": _nameController.text.trim(),
      "image": _localImagePath ?? "",
      "department": _departmentController.text.trim(),
      "contactNumber": getValues(_contactControllers),
      "email": getValues(_emailControllers),
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
      margin: const EdgeInsets.only(bottom: 8),
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
      padding: const EdgeInsets.only(bottom: 6, top: 8),
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
  
  Widget _buildDynamicListSection(String title, String hint, List<TextEditingController> controllers, TextInputType? keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        ...List.generate(controllers.length, (index) {
          return _buildGradientTextField(
            hint: hint, 
            controller: controllers[index],
            keyboardType: keyboardType,
          );
        }),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                controllers.add(TextEditingController());
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              margin: const EdgeInsets.only(bottom: 16, top: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4EAD1), Color(0xFFD7CDE8)],
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black87),
              ),
              child: const Text("Add More", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
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
                        child: _localImagePath != null
                            ? Image.file(File(_localImagePath!), fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("📸", style: TextStyle(fontSize: 50)),
                                  const SizedBox(height: 12),
                                  const Text("Add Image", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel("Name"),
                  _buildGradientTextField(hint: "Name of the faculty", controller: _nameController),
                  
                  _buildLabel("Department"),
                  _buildGradientTextField(hint: "Department of warden", controller: _departmentController),
                  
                  _buildDynamicListSection("Contact", "Contact Number", _contactControllers, TextInputType.phone),
                  _buildDynamicListSection("Email", "Contact Email", _emailControllers, TextInputType.emailAddress),
                  
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

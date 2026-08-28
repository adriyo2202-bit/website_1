import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/data_service.dart';

class ClubEditScreen extends StatefulWidget {
  final String dataKey;
  final Map<String, dynamic>? existingItem;
  final int? itemIndex;

  const ClubEditScreen({
    Key? key,
    required this.dataKey,
    this.existingItem,
    this.itemIndex,
  }) : super(key: key);

  @override
  State<ClubEditScreen> createState() => _ClubEditScreenState();
}

class _ClubEditScreenState extends State<ClubEditScreen> with SingleTickerProviderStateMixin {
  String? _localImagePath;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  List<TextEditingController> _contactNumControllers = [TextEditingController()];
  List<TextEditingController> _contactEmailControllers = [TextEditingController()];
  
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
      _descController.text = item['description'] ?? '';
      
      final images = item['images'];
      if (images != null) {
        if (images is String && images.isNotEmpty) {
          _localImagePath = images;
        } else if (images is List && images.isNotEmpty) {
          _localImagePath = images.first.toString();
        }
      }
      
      if (item['contactNum'] != null) {
        final list = item['contactNum'] as List;
        if (list.isNotEmpty) {
          _contactNumControllers.clear();
          _contactNumControllers.addAll(list.map((c) => TextEditingController(text: c.toString())));
        }
      }
      
      if (item['email'] != null) {
        final list = item['email'] as List;
        if (list.isNotEmpty) {
          _contactEmailControllers.clear();
          _contactEmailControllers.addAll(list.map((c) => TextEditingController(text: c.toString())));
        }
      }
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _nameController.dispose();
    _descController.dispose();
    for (var c in _contactNumControllers) { c.dispose(); }
    for (var c in _contactEmailControllers) { c.dispose(); }
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
      "images": _localImagePath ?? '', // Schema says string
      "contactNum": getValues(_contactNumControllers),
      "email": getValues(_contactEmailControllers),
      "description": _descController.text.trim(),
    };
    
    if (widget.itemIndex != null && widget.itemIndex! < currentList.length) {
      // Retain existing nested arrays
      newItem["facultyAdvisors"] = widget.existingItem?["facultyAdvisors"] ?? [];
      newItem["events"] = widget.existingItem?["events"] ?? [];
      newItem["postHolders"] = widget.existingItem?["postHolders"] ?? [];
      
      currentList[widget.itemIndex!] = newItem;
    } else {
      newItem["facultyAdvisors"] = [];
      newItem["events"] = [];
      newItem["postHolders"] = [];
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
    int maxLines = 1,
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
        maxLines: maxLines,
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
  
  Widget _buildDynamicListSection(String title, String hint, List<TextEditingController> controllers, {TextInputType? keyboardType}) {
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
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFA5A9EB), Color(0xFFFFFFFF), Color(0xFFE0CBE6)],
              ),
            ),
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
                                  const Text("📸", style: TextStyle(fontSize: 50)),
                                  const SizedBox(height: 12),
                                  const Text("Add Logo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel("Name"),
                  _buildGradientTextField(hint: "Name of the club", controller: _nameController),
                  
                  _buildDynamicListSection("Contact Num", "Add contact number", _contactNumControllers, keyboardType: TextInputType.phone),
                  
                  _buildDynamicListSection("Contact Email", "Add contact email", _contactEmailControllers, keyboardType: TextInputType.emailAddress),
                  
                  _buildLabel("Description"),
                  _buildGradientTextField(hint: "Add some description", controller: _descController, maxLines: 5),
                  
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

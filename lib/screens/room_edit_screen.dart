import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'dart:io';
import '../services/data_service.dart';

class RoomEditScreen extends StatefulWidget {
  final String dataKey;
  final Map<String, dynamic>? existingItem;
  final int? itemIndex;
  final String? defaultRoomType;

  const RoomEditScreen({
    Key? key,
    required this.dataKey,
    this.existingItem,
    this.itemIndex,
    this.defaultRoomType,
  }) : super(key: key);

  @override
  State<RoomEditScreen> createState() => _RoomEditScreenState();
}

class _RoomEditScreenState extends State<RoomEditScreen> with SingleTickerProviderStateMixin {
  List<String> _localImagePaths = [];
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomTypeController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  String? _selectedLocation;
  
  bool _isLoading = false;
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    if (widget.defaultRoomType != null) {
      _roomTypeController.text = widget.defaultRoomType!;
    }
    
    _initializeData();
  }
  
  void _initializeData() {
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _nameController.text = item['name'] ?? '';
      _roomTypeController.text = item['roomType'] ?? '';
      _roomNumberController.text = item['roomNumber'] ?? '';
      _buildingController.text = item['buildingName'] ?? '';
      _floorController.text = item['floor']?.toString() ?? '';
      _descController.text = item['description'] ?? '';
      
      if (item['location'] != null) {
        _selectedLocation = "lat: ${item['location']['lat']}, lng: ${item['location']['lng']}";
      }
      
      if (item['images'] != null) {
        final imgs = item['images'] as List;
        _localImagePaths = imgs.map((e) => e.toString()).toList();
      }
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _nameController.dispose();
    _roomTypeController.dispose();
    _roomNumberController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      for (var file in pickedFiles) {
        final File sourceFile = File(file.path);
        final String newLocalPath = await DataService.saveImageForCategory(widget.dataKey, sourceFile);
        _localImagePaths.add(newLocalPath);
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _selectLocation() {
    setState(() {
      _selectedLocation = "lat: 23.5478, lng: 87.2931";
    });
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });
    
    final data = await DataService.loadData();
    final currentList = data[widget.dataKey] as List? ?? [];
    
    Map<String, double>? locationObj;
    if (_selectedLocation != null) {
      locationObj = {"lat": 23.5478, "lng": 87.2931};
    }
    
    final newItem = {
      "id": widget.existingItem?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      "name": _nameController.text.trim(),
      "roomNumber": _roomNumberController.text.trim(),
      "floor": int.tryParse(_floorController.text.trim()) ?? 0,
      "buildingName": _buildingController.text.trim(),
      "roomType": _roomTypeController.text.trim(),
      "images": _localImagePaths,
      "location": locationObj,
      "description": _descController.text.trim(),
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
                  // Image Picker Section
                  SizedBox(
                    height: size.width * 0.4,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...List.generate(_localImagePaths.length, (index) {
                          return Container(
                            width: size.width * 0.4,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(File(_localImagePaths[index])),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _localImagePaths.removeAt(index);
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: size.width * 0.4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF4DEFF), Color(0xFFE6EDFF)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("📸", style: TextStyle(fontSize: 40)),
                                SizedBox(height: 8),
                                Text("Add Images", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel("Name"),
                  _buildGradientTextField(hint: "Name of the room", controller: _nameController),
                  
                  _buildLabel("Location"),
                  GestureDetector(
                    onTap: _selectLocation,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4EAD1), Color(0xFFD7CDE8)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black87),
                      ),
                      child: Text(
                        _selectedLocation ?? "Select Location",
                        style: TextStyle(
                          color: _selectedLocation == null ? Colors.black54 : Colors.black,
                          fontSize: 16,
                          fontWeight: _selectedLocation == null ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  _buildLabel("Room Type"),
                  _buildGradientTextField(hint: "Type of the room", controller: _roomTypeController),
                  
                  _buildLabel("Room Number"),
                  _buildGradientTextField(hint: "Room number", controller: _roomNumberController),
                  
                  _buildLabel("Building Name"),
                  _buildGradientTextField(hint: "Building name", controller: _buildingController),
                  
                  _buildLabel("Floor"),
                  _buildGradientTextField(hint: "Floor number", controller: _floorController, keyboardType: TextInputType.number),
                  
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

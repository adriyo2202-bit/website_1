import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../services/data_service.dart';

class LaboratoryEditScreen extends StatefulWidget {
  final String dataKey;
  final Map<String, dynamic>? existingItem;
  final int? itemIndex;

  const LaboratoryEditScreen({
    Key? key,
    required this.dataKey,
    this.existingItem,
    this.itemIndex,
  }) : super(key: key);

  @override
  State<LaboratoryEditScreen> createState() => _LaboratoryEditScreenState();
}

class _LaboratoryEditScreenState extends State<LaboratoryEditScreen> with SingleTickerProviderStateMixin {
  List<String> _localImagePaths = [];
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  List<String> _locationCoords = [];
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
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
      _buildingController.text = item['buildingName'] ?? '';
      _floorController.text = item['floor'] ?? '';
      _descController.text = item['description'] ?? '';
      
      if (item['images'] != null) {
        _localImagePaths = (item['images'] as List).map((e) => e.toString()).toList();
      }
      
      if (item['locationCord'] != null) {
        _locationCoords = (item['locationCord'] as List).map((e) => e.toString()).toList();
      }
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _nameController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      List<String> newPaths = [];
      for (var pickedFile in pickedFiles) {
        final File sourceFile = File(pickedFile.path);
        final String newLocalPath = await DataService.saveImageForCategory(widget.dataKey, sourceFile);
        newPaths.add(newLocalPath);
      }
      
      setState(() {
        _localImagePaths.addAll(newPaths);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    } 

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _locationCoords = [position.latitude.toString(), position.longitude.toString()];
      _isLoading = false;
    });
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
      "images": _localImagePaths,
      "buildingName": _buildingController.text.trim(),
      "location": _locationCoords,
      "floor": int.tryParse(_floorController.text.trim()) ?? 0,
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
    int maxLines = 1,
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
                  _buildGradientTextField(hint: "Name of the laboratory", controller: _nameController),
                  
                  _buildLabel("Building Name"),
                  _buildGradientTextField(hint: "Building Name", controller: _buildingController),
                  
                  _buildLabel("Location"),
                  GestureDetector(
                    onTap: _fetchLocation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F6ED), Color(0xFFFBE4EA)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black87),
                      ),
                      child: Center(
                        child: Text(
                          _locationCoords.isEmpty ? "Select Location" : "Location Captured: ${_locationCoords[0].substring(0,6)}, ${_locationCoords[1].substring(0,6)}",
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  
                  _buildLabel("Floor"),
                  _buildGradientTextField(hint: "Floor Number", controller: _floorController),
                  
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

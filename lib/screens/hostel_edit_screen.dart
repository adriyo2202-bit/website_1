import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'dart:io';
import '../services/data_service.dart';

class HostelEditScreen extends StatefulWidget {
  final String dataKey;
  final Map<String, dynamic>? existingItem;
  final int? itemIndex;

  const HostelEditScreen({
    Key? key,
    required this.dataKey,
    this.existingItem,
    this.itemIndex,
  }) : super(key: key);

  @override
  State<HostelEditScreen> createState() => _HostelEditScreenState();
}

class _HostelEditScreenState extends State<HostelEditScreen> with SingleTickerProviderStateMixin {
  List<String> _localImagePaths = [];
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hallNumController = TextEditingController();
  String? _selectedHostelType;
  final TextEditingController _capacityController = TextEditingController();
  List<String?> _allocatedSelections = [null];
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
    
    _initializeData();
  }
  
  void _initializeData() {
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _nameController.text = item['name'] ?? '';
      _hallNumController.text = item['hallNo']?.toString() ?? '';
      _selectedHostelType = const ["Boys", "Girls", "Co-Ed"].contains(item['hostelType']) ? item['hostelType'] : null;
      _capacityController.text = item['hallCapacity']?.toString() ?? '';
      _descController.text = item['description'] ?? '';
      
      if (item['location'] != null) {
        _selectedLocation = "lat: ${item['location']['lat']}, lng: ${item['location']['lng']}";
      }
      
      if (item['images'] != null) {
        final imgs = item['images'] as List;
        _localImagePaths = imgs.map((e) => e.toString()).toList();
      }
      
      if (item['allocatedFor'] != null) {
      _allocatedSelections.clear();
        final list = item['allocatedFor'] as List;
        if (list.isNotEmpty) {
          _allocatedSelections.clear();
          _allocatedSelections.addAll(list.map((c) => c.toString()));
      if (_allocatedSelections.isEmpty) _allocatedSelections = [null];
        }
      }
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _nameController.dispose();
    _hallNumController.dispose();
    _capacityController.dispose();
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
    // Dummy GPS selector logic
    setState(() {
      _selectedLocation = "lat: 23.5478, lng: 87.2931"; // NIT DGP coords
    });
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
    
    // Parse location string dummy
    List<double>? _locationCoords;
    if (_selectedLocation != null) {
      _locationCoords = [23.5478, 87.2931];
    }
    
    final newItem = {
      "id": widget.existingItem?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      "name": _nameController.text.trim(),
      "hallNo": int.tryParse(_hallNumController.text.trim()) ?? 0,
      "hostelType": _selectedHostelType ?? "Boys",
      "hallCapacity": int.tryParse(_capacityController.text.trim()) ?? 0,
      "images": _localImagePaths,
      "allocatedFor": _allocatedSelections.where((v) => v != null).toList(),
      "location": _locationCoords,
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
  
  Widget _buildGradientDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6ED), Color(0xFFFBE4EA)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
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
  
  Widget _buildDynamicListSection(String title, String hint, List<TextEditingController> controllers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        ...List.generate(controllers.length, (index) {
          return _buildGradientTextField(
            hint: hint, 
            controller: controllers[index],
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
                  _buildGradientTextField(hint: "Name of the faculty", controller: _nameController),
                  
                  _buildLabel("Hall Number"),
                  _buildGradientTextField(hint: "Hostel Number", controller: _hallNumController, keyboardType: TextInputType.number),
                  
                  _buildLabel("Hostel Type"),
                  _buildGradientDropdown(
                    value: _selectedHostelType,
                    hint: "Select hostel type",
                    items: const ["Boys", "Girls", "Co-Ed"],
                    onChanged: (val) => setState(() => _selectedHostelType = val),
                  ),
                  
                  _buildLabel("Hostel Capacity"),
                  _buildGradientTextField(hint: "Capacity of Hostel", controller: _capacityController, keyboardType: TextInputType.number),
                  
                  
                  _buildLabel("Allocated For"),
                  ...List.generate(_allocatedSelections.length, (index) {
                    return _buildGradientDropdown(
                      value: _allocatedSelections[index],
                      hint: "Select year",
                      items: const ["B.Tech 1st", "B.Tech 2nd", "B.Tech 3rd", "B.Tech 4th", "M.Tech 1st", "M.Tech 2nd", "PhD"],
                      onChanged: (val) {
                        setState(() {
                          _allocatedSelections[index] = val;
                        });
                      },
                    );
                  }),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _allocatedSelections.add(null);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                        margin: const EdgeInsets.only(bottom: 16, top: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5D5F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black87),
                        ),
                        child: const Text("+ Add Year", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                  
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

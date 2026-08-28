import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import '../services/data_service.dart';
import 'department_edit_screen.dart';
import 'department_detail_screen.dart';

class DepartmentListScreen extends StatefulWidget {
  final String title;
  final String dataKey;

  const DepartmentListScreen({
    Key? key,
    required this.title,
    required this.dataKey,
  }) : super(key: key);

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await DataService.loadData();
      setState(() {
        _items = data[widget.dataKey] as List? ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DepartmentEditScreen(
          dataKey: widget.dataKey,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToEditItem(int index, Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DepartmentEditScreen(
          dataKey: widget.dataKey,
          itemIndex: index,
          existingItem: item,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteItem(int index) async {
    final data = await DataService.loadData();
    final currentList = data[widget.dataKey] as List? ?? [];
    
    if (index >= 0 && index < currentList.length) {
      currentList.removeAt(index);
      data[widget.dataKey] = currentList;
      await DataService.saveData(data);
      
      setState(() {
        _items = currentList;
      });
    }
  }

  void _showActionMenu(BuildContext context, int index, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.black87),
                title: const Text('Edit Department', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditItem(index, item);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteItem(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrb(Color color, {double size = 300}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.6),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
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
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi) * size.width * 0.3 - 250,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi) * size.height * 0.3 - 250,
                    child: _buildOrb(const Color(0xFFE0CBE6), size: 500),
                  ),
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi + math.pi) * size.width * 0.4 - 300,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi + math.pi / 2) * size.height * 0.4 - 300,
                    child: _buildOrb(const Color(0xFFF5EFFF), size: 600),
                  ),
                ],
              );
            },
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: GestureDetector(
                    onTap: _navigateToAddItem,
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF4EBFF),
                            Color(0xFFE4EBFF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              const Text("🏢", style: TextStyle(fontSize: 50)),
                              Transform.translate(
                                offset: const Offset(5, 5),
                                child: const Icon(Icons.add, size: 24, color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Add New Department',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Container(
                    height: 1,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // List View
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final images = item['images'] as List?;
                          final name = item['name'] as String? ?? 'Unnamed Department';
                          final localImagePath = (images != null && images.isNotEmpty) ? images.first.toString() : null;
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 500),
                                  pageBuilder: (context, animation, secondaryAnimation) => DepartmentDetailScreen(
                                    department: item,
                                    departmentIndex: index,
                                    dataKey: widget.dataKey,
                                  ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              ).then((_) => _loadData());
                            },
                            onLongPress: () => _showActionMenu(context, index, item),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD4EAD1), Color(0xFFFBE4EA)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Thumbnail
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      image: localImagePath != null
                                        ? DecorationImage(
                                            image: FileImage(File(localImagePath)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    ),
                                    child: localImagePath == null
                                      ? const Icon(Icons.domain, color: Colors.grey)
                                      : null,
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Name
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  
                                  // Arrow Button
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

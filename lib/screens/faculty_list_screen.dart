import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import '../services/data_service.dart';
import 'faculty_edit_screen.dart';

class FacultyListScreen extends StatefulWidget {
  final String title;
  final String dataKey;

  const FacultyListScreen({
    Key? key,
    required this.title,
    required this.dataKey,
  }) : super(key: key);

  @override
  State<FacultyListScreen> createState() => _FacultyListScreenState();
}

class _FacultyListScreenState extends State<FacultyListScreen> with SingleTickerProviderStateMixin {
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

  Future<void> _navigateToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FacultyEditScreen(
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
        builder: (_) => FacultyEditScreen(
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
                title: const Text('Edit Faculty', style: TextStyle(fontWeight: FontWeight.w600)),
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
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Infinite animated background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi) * size.width * 0.3 -
                        250,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi) * size.height * 0.3 -
                        250,
                    child: _buildOrb(const Color(0xFFE0CBE6), size: 500),
                  ),
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi + math.pi) * size.width * 0.4 -
                        300,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi + math.pi / 2) * size.height * 0.4 -
                        300,
                    child: _buildOrb(const Color(0xFFF5EFFF), size: 600),
                  ),
                ],
              );
            },
          ),
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Add New Item Button
                    _buildAddButton(),
                    
                    const SizedBox(height: 30),
                    
                    // Divider
                    Container(
                      height: 1,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Grid Content
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _buildGrid(),
                      
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _navigateToAddItem,
      child: Container(
        width: double.infinity,
        height: 180,
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
                const Text("👨‍🏫", style: TextStyle(fontSize: 50)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.title == 'Faculty Advisors' ? 'Add New Faculty Advisor' : 'Add New Faculty',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_items.isEmpty) {
      // Empty state placeholders
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFDCDCDC),
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final images = item['images'] as List?;
        final name = item['name'] as String?;
        
        return GestureDetector(
          onTap: () => _navigateToEditItem(index, item),
          onLongPress: () => _showActionMenu(context, index, item),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFDCDCDC),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
              image: (images != null && images.isNotEmpty)
                ? DecorationImage(
                    image: FileImage(File(images.first.toString())),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: name != null && name.isNotEmpty
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

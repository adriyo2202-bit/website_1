import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import '../services/data_service.dart';
import 'room_edit_screen.dart';

class RoomListScreen extends StatefulWidget {
  final String title;
  final String dataKey;
  final String filterType;

  const RoomListScreen({
    Key? key,
    required this.title,
    required this.dataKey,
    required this.filterType,
  }) : super(key: key);

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await DataService.loadData();
    setState(() {
      _items = data[widget.dataKey] as List? ?? [];
      _filteredItems = _items.where((item) => item['roomType'] == widget.filterType).toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Widget _buildOrb(Color color, {double size = 300}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomEditScreen(
          dataKey: widget.dataKey,
          defaultRoomType: widget.filterType,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEdit(Map<String, dynamic> item) async {
    final originalIndex = _items.indexOf(item);
    if (originalIndex == -1) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomEditScreen(
          dataKey: widget.dataKey,
          existingItem: item,
          itemIndex: originalIndex,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }
  
  void _deleteItem(Map<String, dynamic> item) async {
    final originalIndex = _items.indexOf(item);
    if (originalIndex == -1) return;
    
    final data = await DataService.loadData();
    final list = data[widget.dataKey] as List? ?? [];
    if (originalIndex < list.length) {
      list.removeAt(originalIndex);
      data[widget.dataKey] = list;
      await DataService.saveData(data);
      _loadData();
    }
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _navigateToAdd,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFE8FE),
              Color(0xFFEAE3FE),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Text(widget.filterType == 'Classroom' ? '👨‍🏫' : '💻', style: const TextStyle(fontSize: 50)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Add New ${widget.filterType}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    String? displayImage;
    if (item['images'] != null && (item['images'] as List).isNotEmpty) {
      displayImage = (item['images'] as List).first.toString();
    }

    return GestureDetector(
      onTap: () => _navigateToEdit(item),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteItem(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: displayImage != null
                  ? Image.file(
                      File(displayImage),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFFF5F5F5),
                      child: Icon(
                        widget.filterType == 'Classroom' ? Icons.class_ : Icons.desktop_windows,
                        size: 40,
                        color: Colors.black26,
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['name'] ?? 'Unnamed',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item['roomNumber'] != null && item['roomNumber'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Room: ${item['roomNumber']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
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
                  Container(color: const Color(0xFFFFFDF4)), // Base color
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi) * size.width * 0.4 -
                        300,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi) * size.height * 0.4 -
                        300,
                    child: _buildOrb(const Color(0xFF987286), size: 600),
                  ),
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi + math.pi) * size.width * 0.5 -
                        300,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi + math.pi / 2) * size.height * 0.4 -
                        300,
                    child: _buildOrb(const Color(0xFFA87676), size: 600),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: SizedBox(
                              height: 180, // Same height logic as other buttons
                              child: _buildAddButton(),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: Divider(color: Colors.black12, thickness: 1),
                          ),
                        ),
                        SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildItemCard(_filteredItems[index]);
                            },
                            childCount: _filteredItems.length,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

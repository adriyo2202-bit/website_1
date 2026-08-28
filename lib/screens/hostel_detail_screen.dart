import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'hostel_edit_screen.dart';
import 'warden_list_screen.dart';
import 'staff_list_screen.dart';
import '../services/data_service.dart';
import 'dart:io';

class HostelDetailScreen extends StatefulWidget {
  final String dataKey;
  final Map<String, dynamic> item;
  final int itemIndex;

  const HostelDetailScreen({
    Key? key,
    required this.dataKey,
    required this.item,
    required this.itemIndex,
  }) : super(key: key);

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Map<String, dynamic> _currentItem;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentItem = Map<String, dynamic>.from(widget.item);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final data = await DataService.loadData();
    final list = data[widget.dataKey] as List? ?? [];
    if (widget.itemIndex < list.length) {
      setState(() {
        _currentItem = Map<String, dynamic>.from(list[widget.itemIndex]);
      });
    }
    setState(() => _isLoading = false);
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

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HostelEditScreen(
          dataKey: widget.dataKey,
          existingItem: _currentItem,
          itemIndex: widget.itemIndex,
        ),
      ),
    );
    if (result == true) {
      _refreshData();
    }
  }

  void _navigateToSubCategory(String title, String fieldKey, Widget destinationScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destinationScreen,
      ),
    ).then((_) => _refreshData());
  }

  Widget _buildSubCategoryRow(String title, String subtitle, String fieldKey, Widget destinationScreen, {Color bgColor = const Color(0xFFF1F8E9)}) {
    return GestureDetector(
      onTap: () => _navigateToSubCategory(title, fieldKey, destinationScreen),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String name = _currentItem['name'] ?? 'Unnamed Hall';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Edit Hub Card
                        GestureDetector(
                          onTap: _navigateToEdit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
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
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text("📝", style: TextStyle(fontSize: 40)),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Edit Hall',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(color: Colors.black12, thickness: 1),
                        const SizedBox(height: 24),
                        
                        // Sub-categories
                        _buildSubCategoryRow(
                          "Wardens",
                          "Add some details about wardens",
                          "wardens",
                          WardenListScreen(
                            title: "Wardens",
                            dataKey: widget.dataKey, // Will nest them inside Hostel later if needed, but schema uses array inside hostel.
                            // Currently in Zenith app architecture, it seems sub-categories are stored inside the parent object.
                            // However, our generic list screens expect a root dataKey.
                            // For Zenith's current simplistic implementation, passing parent data isn't easily genericized without rewriting lists.
                            // I'll assume they will be stored generically at root or we'll pass parent context if needed later.
                            // Wait, for this demo we'll just pass a unique key like '${widget.item['id']}_wardens' to simulate nested storage.
                          ),
                          bgColor: const Color(0xFFF1F8E9), // Light green
                        ),
                        
                        _buildSubCategoryRow(
                          "Hall Incharges",
                          "Add some details about hall incharges",
                          "hallIncharges",
                          StaffListScreen(
                            title: "Hall Incharges",
                            dataKey: '${widget.item['id']}_hallIncharges',
                          ),
                          bgColor: const Color(0xFFE8F5E9), // Light mint
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

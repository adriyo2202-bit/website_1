import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'room_list_screen.dart';
import 'room_edit_screen.dart';

class RoomHubScreen extends StatefulWidget {
  final String title;
  final String dataKey;

  const RoomHubScreen({
    Key? key,
    required this.title,
    required this.dataKey,
  }) : super(key: key);

  @override
  State<RoomHubScreen> createState() => _RoomHubScreenState();
}

class _RoomHubScreenState extends State<RoomHubScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
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

  void _navigateToAddRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomEditScreen(
          dataKey: widget.dataKey,
        ),
      ),
    );
  }

  void _navigateToCategory(String filterType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomListScreen(
          title: "All ${filterType}s",
          dataKey: widget.dataKey,
          filterType: filterType,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, String emoji, String filterType, bool isReverse) {
    return GestureDetector(
      onTap: () => _navigateToCategory(filterType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isReverse)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4DEFF), Color(0xFFE6EDFF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 48)),
            ),
            if (isReverse)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.right,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add New Room Card
                  GestureDetector(
                    onTap: _navigateToAddRoom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 48),
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
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("✏️", style: TextStyle(fontSize: 50)),
                          SizedBox(height: 16),
                          Text(
                            'Add New Room',
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
                  
                  const SizedBox(height: 32),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 32),
                  
                  // Classroom Category
                  _buildCategoryCard(
                    "All ClassRooms",
                    "Inspect all classrooms captured",
                    "👨‍🏫",
                    "ClassRoom",
                    false, // Text on left, emoji on right
                  ),
                  
                  // Office Room Category
                  _buildCategoryCard(
                    "All Offices",
                    "Inspect all officerooms captured",
                    "💻",
                    "Office",
                    true, // Text on right, emoji on left
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

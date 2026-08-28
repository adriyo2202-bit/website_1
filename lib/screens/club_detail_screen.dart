import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'club_edit_screen.dart';
import 'faculty_list_screen.dart';
import 'fest_list_screen.dart';
import 'student_body_list_screen.dart';
import '../services/data_service.dart';
import 'dart:io';

class ClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> club;
  final int clubIndex;
  final String parentDataKey;

  const ClubDetailScreen({
    Key? key,
    required this.club,
    required this.clubIndex,
    required this.parentDataKey,
  }) : super(key: key);

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Map<String, dynamic> _currentClub;

  @override
  void initState() {
    super.initState();
    _currentClub = Map<String, dynamic>.from(widget.club);
    _bgController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _refreshClubData() async {
    final data = await DataService.loadData();
    final clubsList = data[widget.parentDataKey] as List? ?? [];
    if (widget.clubIndex < clubsList.length) {
      setState(() {
        _currentClub = clubsList[widget.clubIndex];
      });
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClubEditScreen(
          dataKey: widget.parentDataKey,
          existingItem: _currentClub,
          itemIndex: widget.clubIndex,
        ),
      ),
    );
    if (result == true) {
      _refreshClubData();
    }
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

  Widget _buildSubCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black87, size: 30),
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
                  const SizedBox(height: 4),
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
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final name = _currentClub['name'] ?? 'Club Details';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          name,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Animation
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi) * size.width * 0.4 -
                        300,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi) * size.height * 0.4 -
                        300,
                    child: _buildOrb(const Color(0xFFD4EAD1), size: 600),
                  ),
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi + math.pi) * size.width * 0.3 -
                        250,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi + math.pi / 2) * size.height * 0.3 -
                        250,
                    child: _buildOrb(const Color(0xFFE0CBE6), size: 500),
                  ),
                ],
              );
            },
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Edit Club Button
                  GestureDetector(
                    onTap: _navigateToEdit,
                    child: Container(
                      width: double.infinity,
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
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text("📝", style: TextStyle(fontSize: 40)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Edit Club",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Container(height: 1, color: Colors.black.withOpacity(0.4)),
                  const SizedBox(height: 24),
                  
                  // Subcategories
                  _buildSubCategoryCard(
                    title: 'Faculty Advisors',
                    subtitle: 'Add some details about faculty advisors',
                    icon: Icons.person_outline,
                    onTap: () {
                      final clubId = _currentClub['id'] ?? widget.clubIndex.toString();
                      final facultyDataKey = 'facultyAdvisors_$clubId';
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FacultyListScreen(
                            dataKey: facultyDataKey,
                            title: 'Faculty Advisors',
                          ),
                        ),
                      );
                    },
                  ),
                  
                  _buildSubCategoryCard(
                    title: 'Events',
                    subtitle: 'Add some details about events organized by this club',
                    icon: Icons.celebration_outlined,
                    onTap: () {
                      final clubId = _currentClub['id'] ?? widget.clubIndex.toString();
                      final eventsDataKey = 'events_$clubId';
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FestListScreen(
                            dataKey: eventsDataKey,
                            title: 'Events',
                          ),
                        ),
                      );
                    },
                  ),
                  
                  _buildSubCategoryCard(
                    title: 'Student Body',
                    subtitle: 'Add some details about student body of this club',
                    icon: Icons.groups_outlined,
                    onTap: () {
                      final clubId = _currentClub['id'] ?? widget.clubIndex.toString();
                      final studentBodyDataKey = 'studentBody_$clubId';
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentBodyListScreen(
                            dataKey: studentBodyDataKey,
                            title: 'Student Body',
                          ),
                        ),
                      );
                    },
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

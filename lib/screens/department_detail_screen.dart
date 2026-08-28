import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'department_edit_screen.dart';
import 'faculty_list_screen.dart';
import 'laboratory_list_screen.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> department;
  final int departmentIndex;
  final String dataKey;

  const DepartmentDetailScreen({
    Key? key,
    required this.department,
    required this.departmentIndex,
    required this.dataKey,
  }) : super(key: key);

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Map<String, dynamic> _currentDepartment;

  @override
  void initState() {
    super.initState();
    _currentDepartment = widget.department;
    _bgController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _navigateToEditDepartment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DepartmentEditScreen(
          dataKey: widget.dataKey,
          itemIndex: widget.departmentIndex,
          existingItem: _currentDepartment,
        ),
      ),
    );
    if (result == true) {
      // Reload is handled by parent, but we can pop to reflect changes
      Navigator.pop(context);
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
            color.withOpacity(0.6),
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.orange, size: 30),
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
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
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
          _currentDepartment['name'] ?? 'Department Details',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                // Edit Department Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: GestureDetector(
                    onTap: _navigateToEditDepartment,
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
                          const Text("📝", style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 12),
                          const Text(
                            'Edit Department',
                            style: TextStyle(
                              fontSize: 18,
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
                
                const SizedBox(height: 24),
                
                // Sub-categories List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildSubCategoryCard(
                        title: 'Faculties',
                        subtitle: 'Add some details about faculties',
                        icon: Icons.person_outline,
                        onTap: () {
                          // Ensure we use a unique key for this department's faculties
                          final deptId = _currentDepartment['id'] ?? widget.departmentIndex.toString();
                          final facultyDataKey = 'faculties_$deptId';
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FacultyListScreen(
                                dataKey: facultyDataKey,
                                title: 'Faculties',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildSubCategoryCard(
                        title: 'Laboratories',
                        subtitle: 'Add some details about laboratories',
                        icon: Icons.science_outlined,
                        onTap: () {
                          final deptId = _currentDepartment['id'] ?? widget.departmentIndex.toString();
                          final labDataKey = 'laboratories_$deptId';
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LaboratoryListScreen(
                                dataKey: labDataKey,
                                title: 'Laboratories',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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

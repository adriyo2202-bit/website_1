import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'widgets/category_card.dart';
import 'screens/category_detail_screen.dart';
import 'screens/department_list_screen.dart';
import 'screens/fest_list_screen.dart';
import 'screens/club_list_screen.dart';
import 'screens/staff_list_screen.dart';
import 'screens/hostel_list_screen.dart';
import 'screens/room_hub_screen.dart';
import 'screens/place_list_screen.dart';
import 'screens/cafeteria_list_screen.dart';
import 'services/data_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIT Durgapur Campus App',
      debugShowCheckedModeBanner: false,
      home: const AnimatedBackgroundPage(),
    );
  }
}

class AnimatedBackgroundPage extends StatefulWidget {
  const AnimatedBackgroundPage({super.key});

  @override
  State<AnimatedBackgroundPage> createState() => _AnimatedBackgroundPageState();
}

class _AnimatedBackgroundPageState extends State<AnimatedBackgroundPage>
    with TickerProviderStateMixin {
  
  // Controller for the infinite floating background blobs
  late AnimationController _bgController;
  
  // Controller for the app opening (splash) animation
  late AnimationController _introController;

  late Animation<Alignment> _alignmentAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<EdgeInsets> _marginAnimation;
  late Animation<double> _listOpacityAnimation;
  
  bool _introFinished = false;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    
    // 15 seconds for a full background orbit animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // 1.5 seconds for the splash screen intro animation
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create a curved animation for a smooth, natural ease-out effect
    final curve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeInOutCubic,
    );

    // Animate from exact center to a little bit up (not fully top)
    _alignmentAnimation = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0, -0.6), // leaves a nice gap at the top
    ).animate(curve);

    // Animate from extra large (400) to a significantly bigger fixed header size (260)
    _sizeAnimation = Tween<double>(
      begin: 400.0,
      end: 260.0,
    ).animate(curve);

    // We don't need top margin anymore since Alignment(0, -0.6) handles the gap naturally
    _marginAnimation = EdgeInsetsTween(
      begin: EdgeInsets.zero,
      end: EdgeInsets.zero,
    ).animate(curve);

    // Fade the list in during the second half of the animation
    _listOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start the intro animation right away
    // We use a slight delay so the user registers the big logo first before it moves
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _introController.forward().then((_) {
          if (mounted) {
            setState(() {
              _introFinished = true;
            });
          }
        });
      }
    });

    // Preload the JSON data from local storage
    DataService.loadData().then((data) {
      if (mounted) {
        setState(() {
          _categories = data['categories'] as List? ?? [];
        });
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      body: Stack(
        children: [
          // Animated Background layer (infinite)
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: size.width * 0.5 +
                        math.cos(_bgController.value * 2 * math.pi) * size.width * 0.4 -
                        250,
                    top: size.height * 0.5 +
                        math.sin(_bgController.value * 2 * math.pi) * size.height * 0.4 -
                        250,
                    child: _buildOrb(const Color(0xFF987286), size: 500),
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
          
          // Foreground Content: Splash Intro Animation OR Smooth Scrolling Home
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _introFinished
                ? _buildSmoothHome(size, key: const ValueKey('home'))
                : _buildSplashIntro(key: const ValueKey('splash')),
          ),
        ],
      ),
    );
  }

  Widget _buildSmoothHome(Size size, {Key? key}) {
    return CustomScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 320.0,
          backgroundColor: Colors.transparent, // Shows the blobs
          elevation: 0,
          pinned: true,
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final top = constraints.biggest.height;
              final safeArea = MediaQuery.of(context).padding.top;
              final isCollapsed = top <= kToolbarHeight + safeArea + 20;

              return FlexibleSpaceBar(
                centerTitle: true,
                background: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: safeArea + 20),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const RadialGradient(
                          center: Alignment.center,
                          radius: 0.5,
                          colors: [Colors.white, Colors.transparent],
                          stops: [0.8, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 260.0,
                        height: 260.0,
                        fit: BoxFit.contain,
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 60),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cat = _categories[index];
                return CategoryCard(
                  title: cat['title'] ?? '',
                  emoji: cat['emoji'] ?? '',
                  subtitlePart1: cat['subtitlePart1'] ?? '',
                  highlightedWord1: cat['highlightedWord1'] ?? '',
                  subtitlePart2: cat['subtitlePart2'] ?? '',
                  highlightedWord2: cat['highlightedWord2'] ?? '',
                  dataKey: cat['dataKey'] ?? '',
                  onTap: () {
                    final isDepartment = cat['dataKey'] == 'departments';
                    final isFest = cat['dataKey'] == 'fests';
                    final isClub = cat['dataKey'] == 'clubs';
                    final isStaff = cat['dataKey'] == 'staff';
                    final isHostel = cat['dataKey'] == 'hostels';
                    final isRoom = cat['dataKey'] == 'rooms';
                    final isPlace = cat['dataKey'] == 'places';
                    final isCafeteria = cat['dataKey'] == 'cafeterias';
                    
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        reverseTransitionDuration: const Duration(milliseconds: 600),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          if (isDepartment) {
                            return DepartmentListScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          if (isFest) {
                            return FestListScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          if (isClub) {
                            return ClubListScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          if (isStaff) {
                            return StaffListScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          if (isHostel) {
                            return HostelListScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          if (isRoom) {
                            return RoomHubScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          if (isPlace) {
                            return PlaceListScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          if (isCafeteria) {
                            return CafeteriaListScreen(
                              title: cat['title'] ?? '',
                              dataKey: cat['dataKey'] ?? '',
                            );
                          }
                          return CategoryDetailScreen(
                            title: cat['title'] ?? '',
                            dataKey: cat['dataKey'] ?? '',
                          );
                        },
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                );
              },
              childCount: _categories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplashIntro({Key? key}) {
    return AnimatedBuilder(
      key: key,
      animation: _introController,
      builder: (context, child) {
        return IgnorePointer(
          child: Align(
            alignment: _alignmentAnimation.value,
            child: Container(
              margin: _marginAnimation.value,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const RadialGradient(
                    center: Alignment.center,
                    radius: 0.5, // Controls how far out the fade starts
                    colors: [Colors.white, Colors.transparent],
                    stops: [0.8, 1.0], // Fade happens entirely in the outer 20%
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                  fit: BoxFit.contain,
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
            ),
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
            color.withOpacity(0.45),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}

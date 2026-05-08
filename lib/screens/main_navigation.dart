import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_weavers_pick_counter/screens/home_screen.dart';
import 'package:the_weavers_pick_counter/screens/showcase_screen.dart';
import 'package:the_weavers_pick_counter/screens/stats_screen.dart';
import 'package:the_weavers_pick_counter/screens/settings_screen.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int index;
  const MainNavigation({super.key, this.index = 0});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;

  final List<Widget> _screens = const [
    HomeScreen(),
    ShowcaseScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16.h,
        top: 10.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 72.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1714).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Counter'),
                _buildNavItem(1, Icons.map_rounded, 'Mill Map'),
                _buildNavItem(2, Icons.book_rounded, 'Logbook'),
                _buildNavItem(3, Icons.tune_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16.w : 14.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              size: 22.sp,
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.firaCode(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

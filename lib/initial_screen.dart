import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_weavers_pick_counter/providers/user_provider.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with TickerProviderStateMixin {
  late AnimationController _marqueeController;

  double _dragOffset = 0.0;
  final double _buttonWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryText,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _marqueeController,
              builder: (context, child) {
                return Stack(
                  children: List.generate(4, (index) {
                    final offset =
                        (index * 250.0) - (_marqueeController.value * 1000.0);
                    return Positioned(
                      top: offset > -250.0 ? offset : offset + 1000.0,
                      left: -200,
                      right: -200,
                      child: Text(
                        'TWPC ' * 8,
                        style: GoogleFonts.firaCode(
                          color: Colors.white.withValues(alpha: 0.02),
                          fontSize: 160.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -5.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kSecondaryAccent.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(kRadiusPill),
                        ),
                        child: Text(
                          'TWPC',
                          style: GoogleFonts.firaCode(
                            fontSize: 16.sp,
                            color: kSecondaryAccent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: kSecondaryAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kSecondaryAccent.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THE WEAVER\'S\nPICK COUNTER',
                            style: GoogleFonts.dmSerifDisplay(
                              color: Colors.white,
                              fontSize: 52.sp,
                              fontWeight: FontWeight.w400,
                              height: 0.95,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Container(
                            width: 60.w,
                            height: 2.h,
                            color: kSecondaryAccent,
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'Catalog the eyes of the mill — precision instruments of the textile trade, preserved in digital archive.',
                            style: GoogleFonts.dmSans(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w300,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxDrag =
                          constraints.maxWidth - (_buttonWidth + 12.w);
                      final progress = (_dragOffset / maxDrag).clamp(0.0, 1.0);

                      return Container(
                        height: 72.h,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Center(
                              child: AnimatedOpacity(
                                opacity: (1 - (progress * 2)).clamp(0.0, 1.0),
                                duration: const Duration(milliseconds: 100),
                                child: Text(
                                  'ENTER THE MILL',
                                  style: GoogleFonts.firaCode(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: _dragOffset.clamp(0.0, maxDrag - 2.w),
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    _dragOffset += details.delta.dx;
                                    if (_dragOffset < 0) {
                                      _dragOffset = 0;
                                    }
                                    if (_dragOffset > maxDrag) {
                                      _dragOffset = maxDrag;
                                    }
                                  });
                                },
                                onHorizontalDragEnd: (details) {
                                  if (_dragOffset > maxDrag * 0.9) {
                                    ref
                                        .read(userProvider)
                                        .setFirstTimeUser(false);
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  } else {
                                    setState(() => _dragOffset = 0);
                                  }
                                },
                                child: Container(
                                  width: _buttonWidth,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    color: Color.lerp(
                                      kSecondaryAccent,
                                      kAccent,
                                      progress,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.lerp(
                                          Colors.black,
                                          kAccent,
                                          progress,
                                        )!.withValues(alpha: 0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                      color: Colors.white,
                                      size: 32.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

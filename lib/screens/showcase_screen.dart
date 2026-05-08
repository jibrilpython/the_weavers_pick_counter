import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_weavers_pick_counter/models/instrument_model.dart';
import 'package:the_weavers_pick_counter/providers/instrument_provider.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';

const Color kWovenIndigo = Color(0xFF1A2433);
const Color kMillBrass = Color(0xFFC2A878);
const Color kSterlingSilver = Color(0xFFE0E4E8);
const Color kBleachedCotton = Color(0xFFF4F1EA);

class SpringNode {
  final TextileInstrumentModel model;
  Offset restPosition;
  Offset currentPosition;
  Offset velocity = Offset.zero;
  bool isDragged = false;
  final int index;

  SpringNode({
    required this.model,
    required this.restPosition,
    required this.index,
  }) : currentPosition = restPosition;

  double get displacement => (currentPosition - restPosition).distance;
}

class RipplePulse {
  Offset origin;
  double radius = 0;
  double opacity = 1.0;
  final double speed;

  RipplePulse({required this.origin, this.speed = 4.0});

  void tick() {
    radius += speed;
    opacity = 1.0 - (radius / 600).clamp(0.0, 1.0);
  }

  bool get isDead => opacity <= 0;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  final List<SpringNode> _nodes = [];
  final List<RipplePulse> _ripples = [];
  bool _isMapBuilt = false;
  int _lastHash = -1;

  SpringNode? _draggedNode;
  bool _loupeLocked = false;
  int? _focusedIndex;

  double _gridCols = 4;
  double _gridRows = 4;
  Offset _gridOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    bool needsUpdate = false;

    for (var node in _nodes) {
      if (!node.isDragged && node.displacement > 0.5) {
        final stiffness = 0.08;
        final damping = 0.75;
        final force = (node.restPosition - node.currentPosition) * stiffness;
        node.velocity = (node.velocity + force) * damping;
        node.currentPosition += node.velocity;
        needsUpdate = true;
      }
    }

    for (int i = _ripples.length - 1; i >= 0; i--) {
      _ripples[i].tick();
      needsUpdate = true;
      if (_ripples[i].isDead) _ripples.removeAt(i);
    }

    if (needsUpdate) setState(() {});
  }

  void _buildLoom(List<TextileInstrumentModel> entries) {
    final currentHash = Object.hash(
      ref.read(instrumentProvider).stateVersion,
      entries.length,
    );
    if (_isMapBuilt && _lastHash == currentHash) return;

    _isMapBuilt = true;
    _lastHash = currentHash;
    _nodes.clear();
    _ripples.clear();

    if (entries.isEmpty) return;

    final size = MediaQuery.of(context).size;
    final padX = 60.w;
    final padY = 160.h;
    final availW = size.width - padX * 2;
    final availH = size.height - padY * 2;

    final count = entries.length;
    _gridCols = math.sqrt(count * (availW / availH)).ceil().toDouble();
    _gridRows = (count / _gridCols).ceil().toDouble();
    _gridCols = _gridCols.clamp(1, count.toDouble());
    _gridRows = _gridRows.clamp(1, count.toDouble());

    final spacingX = availW / (_gridCols + 1);
    final spacingY = availH / (_gridRows + 1);

    _gridOffset = Offset(padX + spacingX, padY + spacingY);

    for (int i = 0; i < entries.length; i++) {
      final col = i % _gridCols.floor();
      final row = (i / _gridCols).floor();
      final x = _gridOffset.dx + col * spacingX;
      final y = _gridOffset.dy + row * spacingY;
      _nodes.add(SpringNode(
        model: entries[i],
        restPosition: Offset(x, y),
        index: i,
      ));
    }
  }

  SpringNode? _hitTestNode(Offset globalPos) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(globalPos);
    for (var node in _nodes) {
      if ((node.currentPosition - local).distance < 40) return node;
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    final node = _hitTestNode(details.globalPosition);
    if (node != null && !_loupeLocked) {
      setState(() {
        _draggedNode = node;
        node.isDragged = true;
        HapticFeedback.selectionClick();
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedNode != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      final local = box.globalToLocal(details.globalPosition);
      setState(() {
        _draggedNode!.currentPosition = local;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggedNode != null) {
      final node = _draggedNode!;
      final dist = node.displacement;
      setState(() {
        node.isDragged = false;
        _draggedNode = null;
      });
      if (dist > 30) {
        HapticFeedback.heavyImpact();
        _addRipple(node.currentPosition);
      } else {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_draggedNode != null) return;
    if (_loupeLocked) return;

    final node = _hitTestNode(details.globalPosition);
    if (node != null) {
      _addRipple(node.currentPosition);
      HapticFeedback.mediumImpact();
      setState(() {
        _loupeLocked = true;
        _focusedIndex = node.index;
      });
    }
  }

  void _addRipple(Offset origin) {
    setState(() {
      _ripples.add(RipplePulse(origin: origin, speed: 6.0));
    });
  }

  void _onStrum(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    _addRipple(local);
    HapticFeedback.lightImpact();
  }

  void _strumUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    _addRipple(local);
  }

  void _releaseLoupe() {
    setState(() {
      _loupeLocked = false;
      _focusedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(instrumentProvider).entries;
    _buildLoom(entries);

    return Scaffold(
      backgroundColor: kWovenIndigo,
      body: entries.isEmpty ? _buildEmptyState() : _buildLoomView(entries),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80.sp, color: kMillBrass.withValues(alpha: 0.2)),
          SizedBox(height: 24.h),
          Text(
            'LOOM OFFLINE',
            style: GoogleFonts.firaCode(
              color: kSterlingSilver,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add instruments to populate the grid',
            style: GoogleFonts.dmSans(
              color: kSterlingSilver.withValues(alpha: 0.5),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoomView(List<TextileInstrumentModel> entries) {
    return GestureDetector(
      onTapUp: _onTapUp,
      onPanStart: (d) {
        if (_hitTestNode(d.globalPosition) != null) {
          _onPanStart(d);
        } else {
          _onStrum(d);
        }
      },
      onPanUpdate: (d) {
        if (_draggedNode != null) {
          _onPanUpdate(d);
        } else {
          _strumUpdate(d);
        }
      },
      onPanEnd: _onPanEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _LoomPainter(
                nodes: _nodes,
                ripples: _ripples,
                cols: _gridCols.floor(),
                rows: _gridRows.floor(),
                gridOffset: _gridOffset,
              ),
              size: Size.infinite,
            ),
          ),
          ..._nodes.map((n) => _buildNode(n)),
          if (!_loupeLocked) _buildHUD(),
          if (_loupeLocked && _focusedIndex != null) ...[
            _buildFocusPanel(entries[_focusedIndex!]),
          ],
          if (!_loupeLocked) _buildLoupeHint(),
        ],
      ),
    );
  }

  Widget _buildNode(SpringNode node) {
    final isDragged = node.isDragged;
    final scale = isDragged ? 1.3 : (1.0 - node.displacement / 400).clamp(0.7, 1.0);

    return Positioned(
      left: node.currentPosition.dx - 24.w * scale,
      top: node.currentPosition.dy - 24.w * scale,
      width: 48.w * scale,
      height: 48.w * scale,
      child: AnimatedOpacity(
        opacity: _loupeLocked ? 0.3 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: isDragged ? kMillBrass : kMillBrass.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDragged ? kBleachedCotton : kSterlingSilver.withValues(alpha: 0.3),
              width: isDragged ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kMillBrass.withValues(alpha: isDragged ? 0.6 : 0.3),
                blurRadius: isDragged ? 24 : 12,
                offset: Offset(0, isDragged ? 8 : 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.remove_red_eye_outlined,
              color: kWovenIndigo,
              size: 20.sp * scale,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 40.h,
      left: 24.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE LOOM',
            style: GoogleFonts.firaCode(
              color: kMillBrass,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Warp & Weft Grid',
            style: GoogleFonts.dmSerifDisplay(
              color: kBleachedCotton,
              fontSize: 32.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kSterlingSilver.withValues(alpha: 0.2)),
            ),
            child: Text(
              'DRAG NODES // TAP TO INSPECT',
              style: GoogleFonts.firaCode(
                color: kSterlingSilver.withValues(alpha: 0.6),
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoupeHint() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 120.h,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: _nodes.isNotEmpty ? 1.0 : 0.0,
            duration: Duration(milliseconds: 800),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: kWovenIndigo.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kMillBrass.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, color: kMillBrass, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'STRUM THE LOOM · TAP TO INSPECT',
                    style: GoogleFonts.firaCode(
                      color: kSterlingSilver,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusPanel(TextileInstrumentModel entry) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
      builder: (context, val, child) {
        return Positioned.fill(
          child: Opacity(
            opacity: val,
            child: child!,
          ),
        );
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: _releaseLoupe,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6 * (1 - 0), sigmaY: 6 * (1 - 0)),
              child: Container(color: kWovenIndigo.withValues(alpha: 0.4)),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: child!,
                );
              },
              child: Container(
                width: 0.85.sw,
                constraints: BoxConstraints(maxHeight: 0.7.sh),
                decoration: BoxDecoration(
                  color: kBleachedCotton,
                  borderRadius: BorderRadius.circular(kRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kRadiusMedium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: kWovenIndigo.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: kWovenIndigo,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.countryOfOrigin.label.toUpperCase(),
                                style: GoogleFonts.firaCode(
                                  color: kMillBrass,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            Spacer(),
                            Text(
                              entry.instrumentType.label.toUpperCase(),
                              style: GoogleFonts.firaCode(
                                color: kWovenIndigo.withValues(alpha: 0.5),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.manufacturer.isNotEmpty
                                    ? entry.manufacturer.toUpperCase()
                                    : 'UNKNOWN MAKER',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSerifDisplay(
                                  color: kWovenIndigo,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 0.95,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(Icons.qr_code_rounded, size: 14.sp, color: kWovenIndigo.withValues(alpha: 0.3)),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      entry.loomIdentifier,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.firaCode(
                                        color: kWovenIndigo.withValues(alpha: 0.5),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              _buildDetailRow('Era', entry.displayEra),
                              _buildDetailRow('Material', entry.materials.label),
                              _buildDetailRow('Condition', entry.condition.label),
                              _buildDetailRow('Operation', entry.operationType.label),
                              if (entry.specificFunction.isNotEmpty)
                                _buildDetailRow('Function', entry.specificFunction),
                              if (entry.provenance.isNotEmpty)
                                _buildDetailRow('Provenance', entry.provenance),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final idx = _focusedIndex;
                          _releaseLoupe();
                          if (idx != null) {
                            Navigator.pushNamed(
                              context,
                              '/info_screen',
                              arguments: {'index': idx},
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          decoration: BoxDecoration(
                            color: kWovenIndigo,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(kRadiusMedium),
                              bottomRight: Radius.circular(kRadiusMedium),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'VIEW FULL DOSSIER',
                              style: GoogleFonts.firaCode(
                                color: kMillBrass,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.firaCode(
                color: kWovenIndigo.withValues(alpha: 0.4),
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                color: kWovenIndigo,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoomPainter extends CustomPainter {
  final List<SpringNode> nodes;
  final List<RipplePulse> ripples;
  final int cols;
  final int rows;
  final Offset gridOffset;

  _LoomPainter({
    required this.nodes,
    required this.ripples,
    required this.cols,
    required this.rows,
    required this.gridOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawWarpWeft(canvas, size);
    _drawRipples(canvas);
  }

  void _drawWarpWeft(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final spacingX = (nodes.length > 1 && cols > 0)
        ? (nodes.last.currentPosition.dx - nodes.first.currentPosition.dx) / (cols - 1).clamp(1, 999)
        : 80.w;
    final spacingY = (nodes.length > 1 && rows > 0)
        ? (nodes.last.currentPosition.dy - nodes.first.currentPosition.dy) / (rows - 1).clamp(1, 999)
        : 80.h;

    if (spacingX < 1 || spacingY < 1) return;

    final gridPts = <int, Map<int, Offset>>{};
    for (int c = 0; c <= cols + 1; c++) {
      gridPts[c] = {};
      for (int r = 0; r <= rows + 1; r++) {
        Offset base;
        if (c == 0 && r == 0) {
          base = Offset(gridOffset.dx - spacingX, gridOffset.dy - spacingY);
        } else if (c == cols + 1 && r == 0) {
          base = Offset(gridOffset.dx + (cols - 1) * spacingX + spacingX, gridOffset.dy - spacingY);
        } else if (c == 0 && r == rows + 1) {
          base = Offset(gridOffset.dx - spacingX, gridOffset.dy + (rows - 1) * spacingY + spacingY);
        } else if (c == cols + 1 && r == rows + 1) {
          base = Offset(gridOffset.dx + (cols - 1) * spacingX + spacingX, gridOffset.dy + (rows - 1) * spacingY + spacingY);
        } else {
          base = Offset(gridOffset.dx + (c - 1) * spacingX, gridOffset.dy + (r - 1) * spacingY);
        }

        Offset displaced = base;
        for (var node in nodes) {
          final dist = (base - node.restPosition).distance;
          if (dist < 200 && node.displacement > 2) {
            final strength = (1 - dist / 200) * node.displacement * 0.3;
            final dir = (base - node.restPosition).distance > 0
                ? (base - node.restPosition) / (base - node.restPosition).distance
                : Offset.zero;
            displaced += dir * strength;
          }
        }

        gridPts[c]![r] = displaced;
      }
    }

    final warpPaint = Paint()
      ..color = kMillBrass.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    final weftPaint = Paint()
      ..color = kSterlingSilver.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    for (int c = 0; c <= cols + 1; c++) {
      for (int r = 0; r < rows + 1; r++) {
        final p1 = gridPts[c]?[r];
        final p2 = gridPts[c]?[r + 1];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, warpPaint);
        }
      }
    }

    for (int r = 0; r <= rows + 1; r++) {
      for (int c = 0; c < cols + 1; c++) {
        final p1 = gridPts[c]?[r];
        final p2 = gridPts[c + 1]?[r];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, weftPaint);
        }
      }
    }

    for (var node in nodes) {
      final dist = node.displacement;
      if (dist > 2) {
        final tensionPaint = Paint()
          ..color = kMillBrass.withValues(alpha: (dist / 200).clamp(0.1, 0.6))
          ..strokeWidth = (dist / 80).clamp(0.5, 2.5)
          ..strokeCap = StrokeCap.round;

        for (int c = -1; c <= 1; c++) {
          for (int r = -1; r <= 1; r++) {
            if (c == 0 && r == 0) continue;
            final nearby = Offset(
              node.restPosition.dx + c * spacingX,
              node.restPosition.dy + r * spacingY,
            );
            if (nearby.dx > 0 && nearby.dx < 5000 && nearby.dy > 0 && nearby.dy < 5000) {
              canvas.drawLine(node.currentPosition, nearby, tensionPaint);
            }
          }
        }
      }
    }

    for (var node in nodes) {
      if (node.displacement > 5) {
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: (node.displacement / 300).clamp(0.05, 0.3))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, node.displacement / 20);
        canvas.drawCircle(
          node.currentPosition,
          20 + node.displacement / 10,
          shadowPaint,
        );
      }
    }
  }

  void _drawRipples(Canvas canvas) {
    for (var r in ripples) {
      final paint = Paint()
        ..color = kMillBrass.withValues(alpha: r.opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(r.origin, r.radius, paint);

      final innerPaint = Paint()
        ..color = kMillBrass.withValues(alpha: r.opacity * 0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(r.origin, r.radius * 0.3, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoomPainter oldDelegate) => true;
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:the_weavers_pick_counter/enum/my_enums.dart';
import 'package:the_weavers_pick_counter/models/instrument_model.dart';
import 'package:the_weavers_pick_counter/providers/image_provider.dart';
import 'package:the_weavers_pick_counter/providers/instrument_provider.dart';
import 'package:the_weavers_pick_counter/providers/search_provider.dart';
import 'package:the_weavers_pick_counter/providers/input_provider.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  InstrumentType? _selectedTypeFilter;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final instrumentProv = ref.watch(instrumentProvider);
    final allEntries = instrumentProv.entries;

    final filteredByType = _selectedTypeFilter == null
        ? allEntries
        : allEntries
              .where((e) => e.instrumentType == _selectedTypeFilter)
              .toList();
    final entries = searchProv.filteredList(filteredByType);

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildHeader(allEntries.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: 28.h),
                      _buildTypeFilterChips(),
                      SizedBox(height: 28.h),
                    ],
                  ),
                ),
              ),
              if (entries.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 140.h),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24.h,
                    crossAxisSpacing: 24.w,
                    childCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final mainIndex = allEntries.indexOf(entry);
                      return _buildInstrumentCard(context, entry, mainIndex);
                    },
                  ),
                ),
            ],
          ),
          Positioned(
            right: 24.w,
            bottom: 120.h,
            child: FloatingActionButton.extended(
              onPressed: () {
                ref.read(inputProvider).clearAll();
                ref.read(imageProvider).clearImage();
                Navigator.pushNamed(context, '/add_screen');
              },
              backgroundColor: kPrimaryText,
              elevation: 8,
              label: Text(
                'ADD INSTRUMENT',
                style: GoogleFonts.firaCode(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              icon: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.h,
        bottom: 20.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE',
                style: GoogleFonts.firaCode(
                  color: kPrimaryText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      'COUNTER',
                      style: GoogleFonts.dmSerifDisplay(
                        color: kPrimaryText,
                        fontSize: 64.sp,
                        fontWeight: FontWeight.w400,
                        height: 0.85,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: kPanelBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kOutline),
                    ),
                    child: Text(
                      count.toString().padLeft(2, '0'),
                      style: GoogleFonts.firaCode(
                        color: kAccent,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'WEAVER\'S PICK COUNTER',
                style: GoogleFonts.firaCode(
                  color: kAccent,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (v) => ref.read(searchProvider.notifier).setSearchQuery(v),
      style: GoogleFonts.dmSans(
        color: kPrimaryText,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'SEARCH INSTRUMENTS...',
        hintStyle: GoogleFonts.dmSans(
          color: kSecondaryText.withValues(alpha: 0.4),
          fontSize: 16.sp,
          letterSpacing: 0.5,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 12.w),
          child: Icon(
            Icons.search_rounded,
            color: isFocused ? kAccent : kSecondaryText.withValues(alpha: 0.5),
            size: 24.sp,
          ),
        ),
        filled: true,
        fillColor: kPanelBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: kOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: kOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: kAccent, width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20.h),
      ),
    );
  }

  Widget _buildTypeFilterChips() {
    return SizedBox(
      height: 48.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _buildChip('ALL', null),
          ...InstrumentType.values.map(
            (t) => _buildChip(t.label.toUpperCase(), t),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, InstrumentType? type) {
    final isSelected = _selectedTypeFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryText : kPanelBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kPrimaryText : kOutline,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.firaCode(
            color: isSelected ? Colors.white : kSecondaryText,
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentCard(
    BuildContext context,
    TextileInstrumentModel entry,
    int mainIndex,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': mainIndex},
      ),
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline, width: 1),
        ),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160.h,
              width: double.infinity,
              child: Hero(
                tag: 'item-$mainIndex',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kBackground.withValues(alpha: 0.5),
                  ),
                  child:
                      (entry.photoPath.isNotEmpty &&
                          imagePath != null &&
                          File(imagePath).existsSync())
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: kSecondaryText.withValues(alpha: 0.1),
                            size: 48.sp,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildThreadGrid(entry, 16),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          entry.loomIdentifier.toUpperCase(),
                          style: GoogleFonts.firaCode(
                            color: entry.condition == ConditionState.pristine
                                ? kAccent
                                : kSecondaryAccent,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    entry.manufacturer.isNotEmpty
                        ? entry.manufacturer
                        : 'Unknown Maker',
                    style: GoogleFonts.dmSans(
                      color: kPrimaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    entry.instrumentType.label.toUpperCase(),
                    style: GoogleFonts.firaCode(
                      color: kSecondaryText,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.magnification.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    _buildMagnificationBadge(entry.magnification),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadGrid(TextileInstrumentModel entry, double size) {
    final isOperational =
        entry.condition == ConditionState.pristine ||
        entry.condition == ConditionState.restored;
    final color = isOperational ? kAccent : kSecondaryAccent;
    final density = entry.instrumentType == InstrumentType.fiberMicrometer
        ? 4
        : entry.instrumentType == InstrumentType.threadReel
        ? 3
        : 2;

    return CustomPaint(
      size: Size(size, size),
      painter: _ThreadGridPainter(color: color, density: density),
    );
  }

  Widget _buildMagnificationBadge(String mag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        border: Border.all(color: kSecondaryAccent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        mag,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.firaCode(
          color: kSecondaryAccent,
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 100.h),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80.sp,
            color: kSecondaryText.withValues(alpha: 0.1),
          ),
          SizedBox(height: 24.h),
          Text(
            'NO INSTRUMENTS IN THIS COUNTER YET.',
            style: GoogleFonts.firaCode(
              color: kSecondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ThreadGridPainter extends CustomPainter {
  final Color color;
  final int density;

  _ThreadGridPainter({required this.color, required this.density});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 0.8;

    final step = size.width / (density + 1);
    for (int i = 1; i <= density; i++) {
      final x = step * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 1; i <= density; i++) {
      final y = step * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThreadGridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.density != density;
}

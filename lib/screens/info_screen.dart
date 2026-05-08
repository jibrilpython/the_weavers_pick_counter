import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_weavers_pick_counter/enum/my_enums.dart';
import 'package:the_weavers_pick_counter/providers/image_provider.dart';
import 'package:the_weavers_pick_counter/providers/instrument_provider.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: kError.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dangerous_rounded,
                  color: kError,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'REMOVE FROM ARCHIVE',
                style: GoogleFonts.firaCode(
                  color: kPrimaryText,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This instrument record will be permanently deleted. This cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: kSecondaryText,
                  fontSize: 16.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusSubtle),
                        ),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.firaCode(
                          color: kSecondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(instrumentProvider).deleteEntry(index);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kError,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusSubtle),
                        ),
                      ),
                      child: Text(
                        'DELETE',
                        style: GoogleFonts.firaCode(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final index = args['index'] as int;

    final instrumentProv = ref.watch(instrumentProvider);
    if (index >= instrumentProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(title: const Text('Instrument Not Found')),
        body: const Center(
          child: Text('The requested instrument could not be found.'),
        ),
      );
    }

    final entry = instrumentProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            stretch: true,
            leadingWidth: 72.w,
            leading: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Container(
                    width: 44.w,
                    height: 44.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Container(
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                onPressed: () => _showDeleteDialog(context, ref, index),
              ),
              SizedBox(width: 8.w),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Container(
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                onPressed: () {
                  ref.read(instrumentProvider).fillInput(ref, index);
                  Navigator.pushNamed(
                    context,
                    '/add_screen',
                    arguments: {'index': index, 'isEdit': true},
                  );
                },
              ),
              SizedBox(width: 16.w),
            ],
            backgroundColor: kPrimaryText,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: 'item-$index',
                child: (entry.photoPath.isNotEmpty &&
                        imagePath != null &&
                        File(imagePath).existsSync())
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Container(
                        color: kSecondaryText,
                        child: Center(
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white.withValues(alpha: 0.2),
                            size: 100.sp,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(kRadiusMedium)),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: kAccentSurface,
                            borderRadius: BorderRadius.circular(kRadiusSubtle),
                          ),
                          child: Text(
                            entry.instrumentType.label.toUpperCase(),
                            style: GoogleFonts.firaCode(
                              color: kAccent,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (entry.era != Era.other)
                          Text(
                            entry.era.label,
                            style: GoogleFonts.dmSans(
                              color: kSecondaryText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      entry.manufacturer.isNotEmpty
                          ? entry.manufacturer
                          : 'Unknown Manufacturer',
                      style: GoogleFonts.dmSerifDisplay(
                        color: kPrimaryText,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'REF: ${entry.loomIdentifier}',
                      style: GoogleFonts.firaCode(
                        color: kSecondaryText,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 48.h),
                    _buildSectionHeader('TECHNICAL SPECIFICATION'),
                    SizedBox(height: 24.h),
                    _buildTechRow('Function', entry.specificFunction),
                    _buildTechRow('Type', entry.instrumentType.label),
                    _buildTechRow('Magnification', entry.magnification),
                    _buildTechRow('Materials', entry.materials.label),
                    _buildTechRow('Operation', entry.operationType.label),
                    _buildTechRow('Country', entry.countryOfOrigin.label),
                    _buildTechRow('Condition', entry.condition.label),
                    _buildTechRow('Dimensions', entry.dimensionsAndWeight),

                    SizedBox(height: 48.h),
                    if (entry.markings.isNotEmpty ||
                        entry.provenance.isNotEmpty) ...[
                      _buildSectionHeader('PROVENANCE & MARKS'),
                      SizedBox(height: 24.h),
                      if (entry.markings.isNotEmpty)
                        _buildMarkingBox('Markings & Stamps', entry.markings),
                      if (entry.provenance.isNotEmpty)
                        _buildMarkingBox('Provenance', entry.provenance),
                    ],
                    if (entry.notes.isNotEmpty) ...[
                      _buildSectionHeader('ARCHIVAL NOTES'),
                      SizedBox(height: 24.h),
                      Text(
                        entry.notes,
                        style: GoogleFonts.dmSans(
                          color: kPrimaryText,
                          fontSize: 16.sp,
                          height: 1.6,
                        ),
                      ),
                    ],
                    if (entry.tags.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: entry.tags.map((tag) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: kBackground,
                            borderRadius: BorderRadius.circular(kRadiusPill),
                            border: Border.all(color: kOutline),
                          ),
                          child: Text(
                            tag.toUpperCase(),
                            style: GoogleFonts.firaCode(
                              color: kSecondaryText,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                    SizedBox(height: 140.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4.w, height: 16.h, color: kAccent),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.firaCode(
            color: kPrimaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTechRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                color: kSecondaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                color: kPrimaryText,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkingBox(String label, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.firaCode(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            text,
            style: GoogleFonts.dmSans(color: kPrimaryText, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }
}

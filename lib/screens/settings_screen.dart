import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_weavers_pick_counter/providers/instrument_provider.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(instrumentProvider).entries;
    final entryCount = entries.length;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40.h,
              bottom: 20.h,
            ),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SETTINGS',
                      style: GoogleFonts.firaCode(
                        color: kAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Archive Config',
                      style: GoogleFonts.dmSerifDisplay(
                        color: kPrimaryText,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w400,
                        height: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.archive_rounded,
                    title: 'Total Instruments',
                    subtitle: '$entryCount cataloged',
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoCard(
                    icon: Icons.info_outline_rounded,
                    title: 'The Weaver\'s Pick Counter',
                    subtitle: 'A digital archive of textile instrumentation',
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoCard(
                    icon: Icons.schedule_rounded,
                    title: 'Last Entry',
                    subtitle: entryCount > 0
                        ? '${_formatDate(entries.last.dateAdded)} — ${entries.last.loomIdentifier}'
                        : 'No entries yet',
                  ),
                  SizedBox(height: 16.h),
                  _buildActionButton(
                    icon: Icons.delete_sweep_rounded,
                    label: 'CLEAR ALL ARCHIVE DATA',
                    isDestructive: true,
                    onTap: () => _showClearAllDialog(context, ref),
                  ),
                  SizedBox(height: 140.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: kAccentSurface,
              borderRadius: BorderRadius.circular(kRadiusSubtle),
            ),
            child: Icon(icon, color: kAccent, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: kPrimaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    color: kSecondaryText,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? kError : kAccent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDestructive ? kError.withValues(alpha: 0.05) : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(
            color: isDestructive ? kError.withValues(alpha: 0.2) : kOutline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(kRadiusSubtle),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.firaCode(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14.sp),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusMedium),
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
                child: Icon(Icons.warning_rounded, color: kError, size: 32.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                'CLEAR ALL DATA?',
                style: GoogleFonts.firaCode(
                  color: kPrimaryText,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This will permanently delete all instrument records. This cannot be undone.',
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
                        final prov = ref.read(instrumentProvider);
                        while (prov.entries.isNotEmpty) {
                          prov.deleteEntry(0);
                        }
                        Navigator.pop(ctx);
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
                        'CLEAR ALL',
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
}

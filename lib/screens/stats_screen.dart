import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_weavers_pick_counter/enum/my_enums.dart';
import 'package:the_weavers_pick_counter/models/instrument_model.dart';
import 'package:the_weavers_pick_counter/providers/instrument_provider.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  InstrumentType? _selectedType;
  Era? _selectedEra;
  bool _showByEra = false;

  List<TextileInstrumentModel> get _filtered {
    final entries = ref.watch(instrumentProvider).entries;
    return entries.where((e) {
      if (_selectedType != null && e.instrumentType != _selectedType) return false;
      if (_selectedEra != null && e.era != _selectedEra) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(instrumentProvider).entries;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildAppBar(context),
          if (entries.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 140.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildFilterChips(entries),
                  SizedBox(height: 24.h),
                  _buildSummaryGrid(filtered, entries.length),
                  SizedBox(height: 32.h),
                  _buildDistributionSection(filtered),
                  SizedBox(height: 32.h),
                  _buildConditionSection(filtered),
                  SizedBox(height: 32.h),
                  _buildSecondaryDistribution(filtered),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 40.h,
        bottom: 32.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOGBOOK',
                style: GoogleFonts.firaCode(
                  color: kAccent,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Archive Intelligence',
                style: GoogleFonts.dmSerifDisplay(
                  color: kPrimaryText,
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w400,
                  height: 0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<TextileInstrumentModel> all) {
    final types = all.map((e) => e.instrumentType).toSet().toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', null, _selectedType == null && _selectedEra == null, () {
                setState(() {
                  _selectedType = null;
                  _selectedEra = null;
                });
              }),
              ...types.map((t) => _filterChip(t.label, t, _selectedType == t, () {
                setState(() {
                  _selectedType = _selectedType == t ? null : t;
                  _selectedEra = null;
                });
              })),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _filterChip(String label, dynamic value, bool selected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? kAccent : kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusPill),
            border: Border.all(
              color: selected ? kAccent : kOutline,
              width: 1,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.firaCode(
              color: selected ? Colors.white : kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(List<TextileInstrumentModel> filtered, int total) {
    final eras = filtered.map((e) => e.era).where((e) => e != Era.other).toSet().length;
    final nations = filtered.map((e) => e.countryOfOrigin).where((c) => c != CountryOfOrigin.other).toSet().length;

    return Row(
      children: [
          Expanded(
            child: _bentoCard('INSTRUMENTS', filtered.length.toString(), kAccent, isDark: true),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _bentoCard('ERAS', eras.toString().padLeft(2, '0'), kSecondaryAccent, isDark: false),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _bentoCard('COUNTRIES', nations.toString().padLeft(2, '0'), kAccent, isDark: false),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _bentoCard('TOTAL', filtered.length.toString(), kSecondaryAccent, isDark: true),
          ),
      ],
    );
  }

  Widget _bentoCard(String label, String value, Color accent, {required bool isDark}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? kPrimaryText : kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: isDark ? null : Border.all(color: kOutline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.firaCode(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : kSecondaryText,
              fontSize: 7.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.dmSerifDisplay(
                      color: isDark ? Colors.white : kPrimaryText,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(List<TextileInstrumentModel> filtered) {
    final counts = <String, int>{};
    final labelMap = <String, String>{};
    final typeMap = <String, InstrumentType>{};
    for (var e in filtered) {
      final key = e.instrumentType.label;
      counts[key] = (counts[key] ?? 0) + 1;
      labelMap[key] = e.instrumentType.label;
      typeMap[key] = e.instrumentType;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('INSTRUMENT SPREAD'),
        SizedBox(height: 20.h),
        ...sorted.map((item) => _buildTappableBar(
          label: labelMap[item.key]!,
          count: item.value,
          maxCount: maxVal,
          total: filtered.length,
          accent: kAccent,
          onTap: () => _showDetailSheet(filtered.where((e) => e.instrumentType == typeMap[item.key]).toList(), item.key),
        )),
      ],
    );
  }

  Widget _buildTappableBar({
    required String label,
    required int count,
    required int maxCount,
    required int total,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final fraction = maxCount > 0 ? count / maxCount : 0.0;
    final pct = total > 0 ? (count / total * 100).toInt() : 0;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline, width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                child: Text(
                  '$pct%',
                  style: GoogleFonts.firaCode(
                    color: kAccent,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: GoogleFonts.firaCode(
                        color: kPrimaryText,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: fraction),
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => SizedBox(
                          height: 6.h,
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: kOutline,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                count.toString().padLeft(2, '0'),
                style: GoogleFonts.firaCode(
                  color: kSecondaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionSection(List<TextileInstrumentModel> filtered) {
    final counts = <ConditionState, int>{};
    for (var e in filtered) {
      counts[e.condition] = (counts[e.condition] ?? 0) + 1;
    }
    final total = filtered.length;
    final pristine = counts[ConditionState.pristine] ?? 0;
    final pct = total == 0 ? 0.0 : pristine / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('PRESERVATION HEALTH'),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline, width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80.w,
                    height: 80.w,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 80.w, height: 80.w,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 10,
                              color: kBackground,
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: 80.w, height: 80.w,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: pct),
                              duration: Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => CircularProgressIndicator(
                                value: value,
                                strokeWidth: 10,
                                color: kAccent,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${(pct * 100).toInt()}%',
                            style: GoogleFonts.firaCode(
                              color: kPrimaryText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: Text(
                      '$pristine of $total instruments in pristine condition.',
                      style: GoogleFonts.dmSans(
                        color: kSecondaryText,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              ...ConditionState.values.map((state) {
                final c = counts[state] ?? 0;
                if (c == 0) return SizedBox.shrink();
                final color = getConditionColor(state);
                final fraction = total > 0 ? c / total : 0.0;
                return GestureDetector(
                  onTap: () => _showConditionDetail(filtered.where((e) => e.condition == state).toList(), state),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w, height: 8.w,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            state.label,
                            style: GoogleFonts.dmSans(
                              color: kPrimaryText,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: fraction),
                              duration: Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => LinearProgressIndicator(
                                value: value,
                                backgroundColor: kOutline,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          c.toString(),
                          style: GoogleFonts.firaCode(
                            color: kSecondaryText,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.chevron_right_rounded, size: 14.sp, color: kSecondaryText),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryDistribution(List<TextileInstrumentModel> filtered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle(_showByEra ? 'ERA DISTRIBUTION' : 'ORIGIN MAP'),
            Spacer(),
            GestureDetector(
              onTap: () => setState(() => _showByEra = !_showByEra),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  border: Border.all(color: kOutline, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showByEra ? Icons.public_rounded : Icons.schedule_rounded,
                      size: 12.sp,
                      color: kAccent,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _showByEra ? 'BY ORIGIN' : 'BY ERA',
                      style: GoogleFonts.firaCode(
                        color: kAccent,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _showByEra ? _buildEraContent(filtered) : _buildOriginContent(filtered),
      ],
    );
  }

  Widget _buildEraContent(List<TextileInstrumentModel> filtered) {
    final counts = <Era, int>{};
    for (var e in filtered) {
      counts[e.era] = (counts[e.era] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: sorted.map((item) {
        return GestureDetector(
          onTap: () => _showEraDetail(filtered.where((e) => e.era == item.key).toList(), item.key),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kOutline, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8.w, height: 8.w, color: kSecondaryAccent),
                SizedBox(width: 10.w),
                Text(
                  item.key.label.toUpperCase(),
                  style: GoogleFonts.firaCode(
                    color: kPrimaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  item.value.toString(),
                  style: GoogleFonts.firaCode(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right_rounded, size: 12.sp, color: kSecondaryText),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOriginContent(List<TextileInstrumentModel> filtered) {
    final counts = <CountryOfOrigin, int>{};
    for (var e in filtered) {
      counts[e.countryOfOrigin] = (counts[e.countryOfOrigin] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: sorted.map((item) {
        return GestureDetector(
          onTap: () => _showOriginDetail(filtered.where((e) => e.countryOfOrigin == item.key).toList(), item.key),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kOutline, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8.w, height: 8.w, color: kAccent),
                SizedBox(width: 10.w),
                Text(
                  item.key.label.toUpperCase(),
                  style: GoogleFonts.firaCode(
                    color: kPrimaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  item.value.toString(),
                  style: GoogleFonts.firaCode(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right_rounded, size: 12.sp, color: kSecondaryText),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDetailSheet(List<TextileInstrumentModel> items, String label) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildEntrySheet(items, label, kAccent),
    );
  }

  void _showConditionDetail(List<TextileInstrumentModel> items, ConditionState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildEntrySheet(items, state.label, getConditionColor(state)),
    );
  }

  void _showEraDetail(List<TextileInstrumentModel> items, Era era) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildEntrySheet(items, era.label, kSecondaryAccent),
    );
  }

  void _showOriginDetail(List<TextileInstrumentModel> items, CountryOfOrigin origin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildEntrySheet(items, origin.label, kAccent),
    );
  }

  Widget _buildEntrySheet(List<TextileInstrumentModel> items, String title, Color accent) {
    return Container(
      height: 0.6.sh,
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusMedium)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: kOutline, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w, height: 32.w,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                  ),
                  child: Center(
                    child: Text(
                      items.length.toString(),
                      style: GoogleFonts.firaCode(
                        color: accent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: GoogleFonts.firaCode(
                      color: kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded, color: kSecondaryText, size: 20.sp),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(24.w),
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(color: kOutline, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w, height: 36.w,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(kRadiusSubtle),
                        ),
                        child: Icon(Icons.remove_red_eye_outlined, color: accent, size: 18.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.loomIdentifier,
                              style: GoogleFonts.dmSans(
                                color: kPrimaryText,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${item.instrumentType.label} · ${item.dateAdded.year}',
                              style: GoogleFonts.dmSans(
                                color: kSecondaryText,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book_outlined,
              size: 80.sp, color: kSecondaryText.withValues(alpha: 0.1)),
          SizedBox(height: 24.h),
          Text(
            'LOGBOOK EMPTY',
            style: GoogleFonts.firaCode(
              color: kPrimaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

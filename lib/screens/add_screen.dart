import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_weavers_pick_counter/common/photo_bottom_sheet.dart';
import 'package:the_weavers_pick_counter/enum/my_enums.dart';
import 'package:the_weavers_pick_counter/providers/image_provider.dart';
import 'package:the_weavers_pick_counter/providers/input_provider.dart';
import 'package:the_weavers_pick_counter/providers/instrument_provider.dart';
import 'package:the_weavers_pick_counter/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _EraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final filtered = text.replaceAll(RegExp(r'[^0-9sS]'), '').toLowerCase();

    if (filtered.isEmpty) return TextEditingValue.empty;

    if (filtered.contains('s') && !filtered.endsWith('s')) {
      final parts = filtered.split('s');
      final fixed = '${parts.first}s';
      return TextEditingValue(
        text: fixed,
        selection: TextSelection.collapsed(offset: fixed.length),
      );
    }

    final digitPart = filtered.replaceAll('s', '');
    if (digitPart.length > 4) return oldValue;
    if (filtered.length > 5) return oldValue;

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late TextEditingController _idCtrl;
  late TextEditingController _funcCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _magCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _markingsCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _customEraCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.loomIdentifier);
    _funcCtrl = TextEditingController(text: p.specificFunction);
    _manCtrl = TextEditingController(text: p.manufacturer);
    _magCtrl = TextEditingController(text: p.magnification);
    _dimCtrl = TextEditingController(text: p.dimensionsAndWeight);
    _customEraCtrl = TextEditingController(text: p.customEra);
    _markingsCtrl = TextEditingController(text: p.markings);
    _provCtrl = TextEditingController(text: p.provenance);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    for (final c in [
      _idCtrl, _funcCtrl, _manCtrl, _magCtrl, _dimCtrl,
      _customEraCtrl, _markingsCtrl, _provCtrl, _notesCtrl, _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() async {
    final p = ref.read(inputProvider);

    p.loomIdentifier = _idCtrl.text;
    p.specificFunction = _funcCtrl.text;
    p.manufacturer = _manCtrl.text;
    p.customEra = _customEraCtrl.text;
    p.magnification = _magCtrl.text;
    p.dimensionsAndWeight = _dimCtrl.text;
    p.markings = _markingsCtrl.text;
    p.provenance = _provCtrl.text;
    p.notes = _notesCtrl.text;
    p.tags = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final bool missingId = _idCtrl.text.trim().isEmpty;

    if (missingId) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('LOOM IDENTIFIER REQUIRED',
            style: GoogleFonts.firaCode(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700)),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(24.w),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusSubtle)),
      ));
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SavingDialog(identifier: _idCtrl.text));

    await Future.delayed(const Duration(milliseconds: 1400));

    if (widget.isEdit) {
      ref.read(instrumentProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(instrumentProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPanelBg,
      appBar: AppBar(
        backgroundColor: kPanelBg.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kPrimaryText, size: 28.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'EDIT INSTRUMENT' : 'NEW INSTRUMENT',
          style: GoogleFonts.firaCode(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: kAccent),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instrument\nDossier.',
                    style: GoogleFonts.dmSerifDisplay(
                      color: kPrimaryText,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w400,
                      height: 0.9,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildPhotoSection(),
                  SizedBox(height: 48.h),
                  _buildSectionTitle('01', 'IDENTIFICATION'),
                  _premiumField(
                    label: 'LOOM IDENTIFIER',
                    ctrl: _idCtrl,
                    hint: 'e.g. TWPC-MACBETH-1920-LANCASHIRE-047',
                    onChanged: (v) =>
                        ref.read(inputProvider).loomIdentifier = v,
                  ),
                  SizedBox(height: 32.h),
                  _buildEnumSelectGroup<InstrumentType>(
                    label: 'INSTRUMENT TYPE',
                    values: InstrumentType.values,
                    current: ref.watch(inputProvider).instrumentType,
                    onSelected: (t) =>
                        ref.read(inputProvider).instrumentType = t,
                    labelBuilder: (t) => t.label,
                  ),
                  _premiumField(
                    label: 'SPECIFIC FUNCTION',
                    ctrl: _funcCtrl,
                    hint: 'e.g. Thread count per inch',
                    onChanged: (v) =>
                        ref.read(inputProvider).specificFunction = v,
                  ),
                  _premiumField(
                    label: 'MANUFACTURER',
                    ctrl: _manCtrl,
                    hint: 'e.g. Alfred Suter',
                    onChanged: (v) =>
                        ref.read(inputProvider).manufacturer = v,
                  ),
                  _buildEnumSelectGroup<CountryOfOrigin>(
                    label: 'COUNTRY OF ORIGIN',
                    values: CountryOfOrigin.values,
                    current: ref.watch(inputProvider).countryOfOrigin,
                    onSelected: (t) =>
                        ref.read(inputProvider).countryOfOrigin = t,
                    labelBuilder: (t) => t.label,
                  ),
                  SizedBox(height: 48.h),
                  _buildSectionTitle('02', 'SPECIFICATIONS'),
                  _buildEnumSelectGroup<Era>(
                    label: 'ERA OF PRODUCTION',
                    values: Era.values,
                    current: ref.watch(inputProvider).era,
                    onSelected: (t) => ref.read(inputProvider).era = t,
                    labelBuilder: (t) => t.label,
                  ),
                  if (ref.watch(inputProvider).era == Era.other)
                    _premiumField(
                      label: 'CUSTOM ERA',
                      ctrl: _customEraCtrl,
                      hint: 'e.g. 1880s, 1960s',
                      onChanged: (v) =>
                          ref.read(inputProvider).customEra = v,
                      inputFormatters: [_EraInputFormatter()],
                    ),
                  _premiumField(
                    label: 'MAGNIFICATION / PRECISION',
                    ctrl: _magCtrl,
                    hint: 'e.g. 10x, 280 EPI max',
                    onChanged: (v) =>
                        ref.read(inputProvider).magnification = v,
                  ),
                  _buildEnumSelectGroup<InstrumentMaterial>(
                    label: 'MATERIALS',
                    values: InstrumentMaterial.values,
                    current: ref.watch(inputProvider).materials,
                    onSelected: (t) => ref.read(inputProvider).materials = t,
                    labelBuilder: (t) => t.label,
                  ),
                  _buildEnumSelectGroup<OperationType>(
                    label: 'OPERATION TYPE',
                    values: OperationType.values,
                    current: ref.watch(inputProvider).operationType,
                    onSelected: (t) =>
                        ref.read(inputProvider).operationType = t,
                    labelBuilder: (t) => t.label,
                  ),
                  _premiumField(
                    label: 'DIMENSIONS & WEIGHT',
                    ctrl: _dimCtrl,
                    hint: 'L x W x H, weight',
                    onChanged: (v) =>
                        ref.read(inputProvider).dimensionsAndWeight = v,
                  ),
                  SizedBox(height: 48.h),
                  _buildSectionTitle('03', 'ARCHIVAL'),
                  _buildEnumSelectGroup<ConditionState>(
                    label: 'CONDITION',
                    values: ConditionState.values,
                    current: ref.watch(inputProvider).condition,
                    onSelected: (t) => ref.read(inputProvider).condition = t,
                    labelBuilder: (t) => t.label.split('—')[0],
                  ),
                  _premiumField(
                    label: 'MARKINGS & STAMPS',
                    ctrl: _markingsCtrl,
                    hint: 'Hallmarks, inventory numbers, patent dates',
                    onChanged: (v) => ref.read(inputProvider).markings = v,
                  ),
                  _premiumField(
                    label: 'PROVENANCE',
                    ctrl: _provCtrl,
                    hint: 'Where found',
                    onChanged: (v) => ref.read(inputProvider).provenance = v,
                  ),
                  _premiumField(
                    label: 'TAGS',
                    ctrl: _tagsCtrl,
                    hint: 'Comma-separated tags',
                    onChanged: (v) {},
                  ),
                  _premiumField(
                    label: 'NOTES',
                    ctrl: _notesCtrl,
                    hint: 'Archival notes...',
                    maxLines: 4,
                    onChanged: (v) => ref.read(inputProvider).notes = v,
                  ),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String num, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32.h),
      child: Row(
        children: [
          Text(num,
              style: GoogleFonts.firaCode(
                  color: kAccent,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(width: 12.w),
          Container(
              width: 30.w,
              height: 1.h,
              color: kSecondaryText.withValues(alpha: 0.3)),
          SizedBox(width: 12.w),
          Text(text,
              style: GoogleFonts.firaCode(
                  color: kPrimaryText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _premiumField({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.firaCode(
                color: kSecondaryText,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0),
          ),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.dmSans(
                color: kPrimaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.dmSans(
                  color: kSecondaryText.withValues(alpha: 0.3),
                  fontSize: 18.sp),
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: kBackground, width: 2.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: kAccent, width: 2.0)),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnumSelectGroup<T>({
    required String label,
    required List<T> values,
    required T current,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.firaCode(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: values.map((val) {
            final isSel = val == current;
            return GestureDetector(
              onTap: () => onSelected(val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSel ? kPrimaryText : kBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  labelBuilder(val).toUpperCase(),
                  style: GoogleFonts.dmSans(
                    color: isSel ? Colors.white : kPrimaryText,
                    fontSize: 13.sp,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () =>
          photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 240.h,
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: imgPath != null && File(imgPath).existsSync()
            ? Image.file(File(imgPath), fit: BoxFit.cover)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        color: kSecondaryText.withValues(alpha: 0.5),
                        size: 40.sp),
                    SizedBox(height: 12.h),
                    Text('UPLOAD PHOTOGRAPH',
                        style: GoogleFonts.firaCode(
                            color: kSecondaryText,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24.w, 16.h, 24.w, MediaQuery.of(context).padding.bottom + 16.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 64.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusSubtle)),
          elevation: 0,
        ),
        child: Text(
          widget.isEdit ? 'UPDATE ARCHIVE' : 'SUBMIT TO REGISTRY',
          style: GoogleFonts.dmSans(
              fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  final String identifier;
  const _SavingDialog({required this.identifier});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccent.withValues(alpha: 0.08),
              ),
              child: Center(
                child: SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: CircularProgressIndicator(
                    color: kAccent,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'CATALOGING INSTRUMENT',
              style: GoogleFonts.firaCode(
                color: kPrimaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              identifier,
              style: GoogleFonts.dmSerifDisplay(
                color: kAccent,
                fontSize: 22.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16.h),
            Text(
              'Writing to permanent archive…',
              style: GoogleFonts.dmSans(
                color: kSecondaryText,
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

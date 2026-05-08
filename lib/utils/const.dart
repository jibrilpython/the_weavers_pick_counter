import 'package:flutter/material.dart';
import 'package:the_weavers_pick_counter/enum/my_enums.dart';

const Color kBackground = Color(0xFFF7F5F2);
const Color kPrimaryText = Color(0xFF1A1714);
const Color kPanelBg = Color(0xFFFFFFFF);
const Color kSecondaryText = Color(0xFF7C7870);
const Color kAccent = Color(0xFF5C4A8A);
const Color kSecondaryAccent = Color(0xFFB07A2E);
const Color kOutline = Color(0xFFEAE7E0);
const Color kError = Color(0xFFC0392B);

const Color kAccentLight = Color(0xFF7C6A9E);
const Color kAccentSurface = Color(0xFFF3F0FA);
const Color kGoldSurface = Color(0x1AB07A2E);
const Color kGlassBackground = Color(0xB3FFFFFF);

const double kSpacingXXS = 4.0;
const double kSpacingXS = 8.0;
const double kSpacingS = 12.0;
const double kSpacingM = 16.0;
const double kSpacingL = 20.0;
const double kSpacingXL = 24.0;
const double kSpacingXXL = 32.0;
const double kSpacingXXXL = 48.0;

const double kRadiusZero = 0.0;
const double kRadiusSubtle = 10.0;
const double kRadiusStandard = 16.0;
const double kRadiusMedium = 24.0;
const double kRadiusLarge = 32.0;
const double kRadiusPill = 999.0;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 16),
  blurRadius: 40,
  spreadRadius: -12,
  color: Color(0x14000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 32),
  blurRadius: 64,
  spreadRadius: -16,
  color: Color(0x1A000000),
);

const BoxShadow kShadowGlass = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 32,
  spreadRadius: 0,
  color: Color(0x0A000000),
);

const double kStrokeWeight = 1.0;
const double kStrokeWeightMedium = 2.0;
const double kStrokeWeightThick = 3.0;

Color getMaterialColor(InstrumentMaterial mat) {
  switch (mat) {
    case InstrumentMaterial.polishedBrass:
      return const Color(0xFFB07A2E);
    case InstrumentMaterial.castIron:
      return const Color(0xFF3D3D3D);
    case InstrumentMaterial.vulcanite:
      return const Color(0xFF2D2D2D);
    case InstrumentMaterial.glassOptics:
      return const Color(0xFF8EC8E8);
    case InstrumentMaterial.nickelPlating:
      return const Color(0xFFC0C0C0);
    case InstrumentMaterial.other:
      return const Color(0xFF6A6A6A);
  }
}

Color getConditionColor(ConditionState state) {
  switch (state) {
    case ConditionState.pristine:
      return kAccent;
    case ConditionState.restored:
      return kSecondaryAccent;
    case ConditionState.minorWear:
      return kSecondaryText;
    case ConditionState.corroded:
      return const Color(0xFFC88241);
    case ConditionState.immobile:
      return kError;
    case ConditionState.unknown:
      return kSecondaryText;
  }
}

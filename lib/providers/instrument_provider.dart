import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_weavers_pick_counter/models/instrument_model.dart';
import 'package:the_weavers_pick_counter/providers/image_provider.dart';
import 'package:the_weavers_pick_counter/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InstrumentNotifier extends ChangeNotifier {
  InstrumentNotifier() {
    loadEntries();
  }

  List<TextileInstrumentModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'twpc_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => TextileInstrumentModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    final newEntry = TextileInstrumentModel(
      id: _uuid.v4(),
      loomIdentifier: p.loomIdentifier,
      instrumentType: p.instrumentType,
      specificFunction: p.specificFunction,
      manufacturer: p.manufacturer,
      countryOfOrigin: p.countryOfOrigin,
      era: p.era,
      customEra: p.customEra,
      magnification: p.magnification,
      materials: p.materials,
      operationType: p.operationType,
      dimensionsAndWeight: p.dimensionsAndWeight,
      condition: p.condition,
      markings: p.markings,
      provenance: p.provenance,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: p.dateAdded,
    );

    entries = [...entries, newEntry];
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    final updatedEntry = TextileInstrumentModel(
      id: existing.id,
      loomIdentifier: p.loomIdentifier,
      instrumentType: p.instrumentType,
      specificFunction: p.specificFunction,
      manufacturer: p.manufacturer,
      countryOfOrigin: p.countryOfOrigin,
      era: p.era,
      customEra: p.customEra,
      magnification: p.magnification,
      materials: p.materials,
      operationType: p.operationType,
      dimensionsAndWeight: p.dimensionsAndWeight,
      condition: p.condition,
      markings: p.markings,
      provenance: p.provenance,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty ? imgProv.resultImage : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    final newList = List<TextileInstrumentModel>.from(entries);
    newList[index] = updatedEntry;
    entries = newList;

    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    final newList = List<TextileInstrumentModel>.from(entries);
    newList.removeAt(index);
    entries = newList;

    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.loomIdentifier = entry.loomIdentifier;
    p.instrumentType = entry.instrumentType;
    p.specificFunction = entry.specificFunction;
    p.manufacturer = entry.manufacturer;
    p.countryOfOrigin = entry.countryOfOrigin;
    p.era = entry.era;
    p.customEra = entry.customEra;
    p.magnification = entry.magnification;
    p.materials = entry.materials;
    p.operationType = entry.operationType;
    p.dimensionsAndWeight = entry.dimensionsAndWeight;
    p.condition = entry.condition;
    p.markings = entry.markings;
    p.provenance = entry.provenance;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final instrumentProvider = ChangeNotifierProvider<InstrumentNotifier>(
  (ref) => InstrumentNotifier(),
);

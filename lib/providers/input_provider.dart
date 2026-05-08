import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_weavers_pick_counter/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _loomIdentifier = '';
  InstrumentType _instrumentType = InstrumentType.foldingPickCounter;
  String _specificFunction = '';
  String _manufacturer = '';
  CountryOfOrigin _countryOfOrigin = CountryOfOrigin.other;
  Era _era = Era.other;
  String _customEra = '';
  String _magnification = '';
  InstrumentMaterial _materials = InstrumentMaterial.other;
  OperationType _operationType = OperationType.other;
  String _dimensionsAndWeight = '';
  ConditionState _condition = ConditionState.unknown;
  String _markings = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get loomIdentifier => _loomIdentifier;
  InstrumentType get instrumentType => _instrumentType;
  String get specificFunction => _specificFunction;
  String get manufacturer => _manufacturer;
  CountryOfOrigin get countryOfOrigin => _countryOfOrigin;
  Era get era => _era;
  String get customEra => _customEra;
  String get magnification => _magnification;
  InstrumentMaterial get materials => _materials;
  OperationType get operationType => _operationType;
  String get dimensionsAndWeight => _dimensionsAndWeight;
  ConditionState get condition => _condition;
  String get markings => _markings;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set loomIdentifier(String v) { _loomIdentifier = v; notifyListeners(); }
  set instrumentType(InstrumentType v) { _instrumentType = v; notifyListeners(); }
  set specificFunction(String v) { _specificFunction = v; notifyListeners(); }
  set manufacturer(String v) { _manufacturer = v; notifyListeners(); }
  set countryOfOrigin(CountryOfOrigin v) { _countryOfOrigin = v; notifyListeners(); }
  set era(Era v) { _era = v; notifyListeners(); }
  set customEra(String v) { _customEra = v; notifyListeners(); }
  set magnification(String v) { _magnification = v; notifyListeners(); }
  set materials(InstrumentMaterial v) { _materials = v; notifyListeners(); }
  set operationType(OperationType v) { _operationType = v; notifyListeners(); }
  set dimensionsAndWeight(String v) { _dimensionsAndWeight = v; notifyListeners(); }
  set condition(ConditionState v) { _condition = v; notifyListeners(); }
  set markings(String v) { _markings = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _loomIdentifier = '';
    _instrumentType = InstrumentType.foldingPickCounter;
    _specificFunction = '';
    _manufacturer = '';
    _countryOfOrigin = CountryOfOrigin.other;
    _era = Era.other;
    _customEra = '';
    _magnification = '';
    _materials = InstrumentMaterial.other;
    _operationType = OperationType.other;
    _dimensionsAndWeight = '';
    _condition = ConditionState.unknown;
    _markings = '';
    _provenance = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);

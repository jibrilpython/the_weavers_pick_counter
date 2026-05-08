import 'package:the_weavers_pick_counter/enum/my_enums.dart';

class TextileInstrumentModel {
  String id;
  String loomIdentifier;
  InstrumentType instrumentType;
  String specificFunction;
  String manufacturer;
  CountryOfOrigin countryOfOrigin;
  Era era;
  String customEra;
  String magnification;
  InstrumentMaterial materials;
  OperationType operationType;
  String dimensionsAndWeight;
  ConditionState condition;
  String markings;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  TextileInstrumentModel({
    required this.id,
    required this.loomIdentifier,
    required this.instrumentType,
    this.specificFunction = '',
    this.manufacturer = '',
    this.countryOfOrigin = CountryOfOrigin.other,
    this.era = Era.other,
    this.customEra = '',
    this.magnification = '',
    this.materials = InstrumentMaterial.other,
    this.operationType = OperationType.other,
    this.dimensionsAndWeight = '',
    this.condition = ConditionState.unknown,
    this.markings = '',
    this.provenance = '',
    this.notes = '',
    this.photoPath = '',
    this.tags = const [],
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  String get displayEra =>
      era == Era.other && customEra.isNotEmpty ? customEra : era.label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'loomIdentifier': loomIdentifier,
        'instrumentType': instrumentType.name,
        'specificFunction': specificFunction,
        'manufacturer': manufacturer,
        'countryOfOrigin': countryOfOrigin.name,
        'era': era.name,
        'customEra': customEra,
        'magnification': magnification,
        'materials': materials.name,
        'operationType': operationType.name,
        'dimensionsAndWeight': dimensionsAndWeight,
        'condition': condition.name,
        'markings': markings,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory TextileInstrumentModel.fromJson(Map<String, dynamic> json) =>
      TextileInstrumentModel(
        id: json['id'] ?? '',
        loomIdentifier: json['loomIdentifier'] ?? '',
        instrumentType: InstrumentType.values.asNameMap()[json['instrumentType']] ?? InstrumentType.other,
        specificFunction: json['specificFunction'] ?? '',
        manufacturer: json['manufacturer'] ?? '',
        countryOfOrigin: CountryOfOrigin.values.asNameMap()[json['countryOfOrigin']] ?? CountryOfOrigin.other,
        era: Era.values.asNameMap()[json['era']] ?? Era.other,
        customEra: json['customEra'] ?? '',
        magnification: json['magnification'] ?? '',
        materials: InstrumentMaterial.values.asNameMap()[json['materials']] ?? InstrumentMaterial.other,
        operationType: OperationType.values.asNameMap()[json['operationType']] ?? OperationType.other,
        dimensionsAndWeight: json['dimensionsAndWeight'] ?? '',
        condition: ConditionState.values.asNameMap()[json['condition']] ?? ConditionState.unknown,
        markings: json['markings'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}

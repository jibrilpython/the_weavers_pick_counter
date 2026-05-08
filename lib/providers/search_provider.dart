import 'package:the_weavers_pick_counter/models/instrument_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<TextileInstrumentModel> filteredList(List<TextileInstrumentModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.loomIdentifier.toLowerCase().contains(query) ||
              item.manufacturer.toLowerCase().contains(query) ||
              item.countryOfOrigin.label.toLowerCase().contains(query) ||
              item.specificFunction.toLowerCase().contains(query) ||
              item.provenance.toLowerCase().contains(query) ||
              item.era.label.toLowerCase().contains(query) ||
              item.instrumentType.label.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());

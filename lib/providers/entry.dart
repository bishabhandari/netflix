import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../api/cilent.dart';
import '../data/entry.dart';

class EntryProvider extends ChangeNotifier {
  Map<String, Uint8List> _imageCache = {};

  final String _collectionId = "6497ecea06a1b575e11c";
  final String _databaseId = "6497ecd23edc88834dfd";
  final String _bucketId = "64994eb27ef7bfb088c4";

  Entry? _selected;
  Entry? get selected => _selected;

  Entry _featured = Entry.empty();
  Entry get featured => _featured;

  List<Entry> _entries = [];
  List<Entry> get entries => _entries;
  List<Entry> get originals =>
      _entries.where((e) => e.isOriginal == true).toList();
  List<Entry> get animations =>
      _entries.where((e) => e.genres.toLowerCase().contains('animation')).toList();
  List<Entry> get newReleases => _entries
      .where((e) => e.releaseDate != null && e.releaseDate!.isAfter(DateTime.parse('2018-01-01')))
      .toList();

  List<Entry> get trending {
    var trending = _entries;

    trending.sort((a, b) => b.trendingIndex.compareTo(a.trendingIndex));

    return trending;
  }

  void setSelected(Entry entry) {
    _selected = entry;

    notifyListeners();
  }

  Future<void> list() async {
    try {
      var result = await ApiClient.database.listDocuments(collectionId: _collectionId, databaseId: _databaseId);

      _entries = result.documents.map((document) => Entry.fromJson(document.data)).toList();
      _featured = _entries.isEmpty ? Entry.empty() : _entries[0];

      notifyListeners();
    } catch (e) {
      print('Error occurred while listing entries: $e');
      // Handle the error as needed
    }
  }

  Future<Uint8List> imageFor(Entry entry) async {
    if (_imageCache.containsKey(entry.thumbnailImageId)) {
      return _imageCache[entry.thumbnailImageId]!;
    }

    try {
      final result = await ApiClient.storage.getFileView(fileId: entry.thumbnailImageId, bucketId: _bucketId);

      _imageCache[entry.thumbnailImageId] = result;

      return result;
    } catch (e) {
      print('Error occurred while retrieving image for entry: $e');
      // Handle the error as needed
      return Uint8List(0); // Return an empty Uint8List or a placeholder image
    }
  }
}

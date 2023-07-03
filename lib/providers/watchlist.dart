import 'dart:async';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

import '../api/cilent.dart';
import '../data/entry.dart';

class WatchListProvider extends ChangeNotifier {
  final String _collectionId = "6497f834891668136704";
  final String _databaseId = '6497ecd23edc88834dfd';

  List<Entry> _entries = [];
  List<Entry> get entries => _entries;

  Future<User> get user async {
    return await ApiClient.account.get();
  }

  Future<List<Entry>> list() async {
    final user = await this.user;

    final watchlist = await ApiClient.database.listDocuments(
      collectionId: _collectionId,
      databaseId: _databaseId,
    );

    final movieIds = watchlist.documents
        .map((document) => document.data["movieId"])
        .toList();
    final entries = (await ApiClient.database.listDocuments(
            collectionId: _collectionId, databaseId: _databaseId))
        .documents
        .map((document) => Entry.fromJson(document.data))
        .toList();
    final filtered =
        entries.where((entry) => movieIds.contains(entry.id)).toList();

    _entries = filtered;

    notifyListeners();

    return _entries;
  }

  Future<void> add(Entry entry) async {
    final user = await this.user;

    var result = await ApiClient.database.createDocument(
        collectionId: _collectionId,
        documentId: 'unique()',
        data: {
          "userId": user.$id,
          "movieId": entry.id,
          "createdAt": (DateTime.now().second / 1000).round()
        },
        databaseId: '6497ecd23edc88834dfd');

    _entries.add(Entry.fromJson(result.data));

    list();
  }

  Future<void> remove(Entry entry) async {
    final user = await this.user;

    final result = await ApiClient.database.listDocuments(
        collectionId: _collectionId,
        queries: [
          Query.equal("userId", user.$id),
          Query.equal("movieId", entry.id),
        ],
        databaseId: '6497ecd23edc88834dfd');

    final id = result.documents.first.$id;

    await ApiClient.database.deleteDocument(
        collectionId: _collectionId,
        documentId: id,
        databaseId: '6497ecd23edc88834dfd');

    list();
  }

  Future<Uint8List> imageFor(Entry entry) async {
    return await ApiClient.storage.getFileView(
        fileId: entry.thumbnailImageId, bucketId: '64994eb27ef7bfb088c4');
  }

  bool isOnList(Entry entry) => _entries.any((e) => e.id == entry.id);
}

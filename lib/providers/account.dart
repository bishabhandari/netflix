import 'dart:convert';

import 'package:appwrite/models.dart' ;
import 'package:flutter/material.dart';
import 'package:netflix/data/store.dart';

import '../api/cilent.dart';

class AccountProvider extends ChangeNotifier {
  User? _current;
  User? get current => _current;

  Session? _session;
  Session? get session => _session;

  Future<Session?> get _cachedSession async {
    final cached = await Store.get("session");

    if (cached == null) {
      return null;
    }

    return Session.fromMap(json.decode(cached));
  }

  Future<bool> isValid() async {
    if (session == null) {
      final cached = await _cachedSession;

      if (cached == null) {
        return false;
      }

      _session = cached;
    }

    return _session != null;
  }

  Future<void> register(String email, String password, String? name) async {
    try {
      final result = await ApiClient.account.create(
        userId: 'unique()',
        email: email,
        password: password,
        name: name,
      );

      _current = result;

      notifyListeners();
    } catch (e) {
  throw Exception("Failed to register: $e");
}

  }

  Future<void> login(String email, String password) async {
    try {
      final result = await ApiClient.account.createEmailSession(
          email: email, password: password);
      _session = result;

      Store.set("session", json.encode(result.toMap()));

      notifyListeners();
    } catch (e) {
      _session = null;
    }
  }
  
  // Add the additional code here
  
  String? get registeredUserEmail {
    return _current?.email;
  }
}


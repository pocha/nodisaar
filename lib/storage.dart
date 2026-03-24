import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppStorage {
  static const _keyItems    = 'watchItems';
  static const _keyUsername = 'username';
  static const _keyDocId    = 'userDocId';
  static const _keyFriends  = 'friendUsernames'; // List<String>

  // ── Watch items (own) ──────────────────────────────────────────────────────
  static Future<List<WatchItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyItems) ?? [];
    return raw.map((s) => WatchItem.fromMap(jsonDecode(s))).toList();
  }

  static Future<void> setItems(List<WatchItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyItems,
      items.map((i) => jsonEncode(i.toLocal())).toList(),
    );
  }

  static Future<void> addItem(WatchItem item) async {
    final items = await getItems();
    if (!items.any((i) => i.href == item.href)) {
      items.add(item);
      await setItems(items);
    }
  }

  static Future<void> removeItem(String href) async {
    final items = await getItems();
    items.removeWhere((i) => i.href == href);
    await setItems(items);
  }

  // ── User identity ──────────────────────────────────────────────────────────
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  static Future<String?> getDocId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDocId);
  }

  static Future<void> setDocId(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDocId, docId);
  }

  // ── Friends ────────────────────────────────────────────────────────────────
  static Future<List<String>> getFriendUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFriends) ?? [];
  }

  static Future<void> addFriendUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyFriends) ?? [];
    if (!list.contains(username)) {
      list.add(username);
      await prefs.setStringList(_keyFriends, list);
    }
  }
}
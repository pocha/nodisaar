import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';
import 'storage.dart';
import 'package:http/http.dart' as http;


class FirebaseService {
  static const _base = 'https://asia-south1-nodi-saar.cloudfunctions.net';
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ── Anonymous auth ─────────────────────────────────────────────────────────
  static Future<String> ensureAuth() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    return _auth.currentUser!.uid;
  }

  // ── Username check (HTTP — safe public query) ──────────────────────────────
  static Future<bool> checkUsername(String username) async {
    final uri = Uri.parse(
        '$_base/checkUsername?username=${Uri.encodeComponent(username)}');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return false;
    return jsonDecode(resp.body)['available'] == true;
  }

  // ── Save own list to Firestore ─────────────────────────────────────────────
  // Compares local items against Firestore, batches only the delta.
  // Returns true if anything was written.
  static Future<bool> syncItems(List<WatchItem> localItems) async {
    await ensureAuth();
    String? docId = await AppStorage.getDocId();
    final username = await AppStorage.getUsername();

    // Create user doc if first save
    if (docId == null) {
      final ref = _db.collection('Users').doc();
      await ref.set({
        'username': username ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      docId = ref.id;
      await AppStorage.setDocId(docId);
    } else if (username != null) {
      // Keep username field in sync if it changed
      await _db.collection('Users').doc(docId).set(
        {'username': username},
        SetOptions(merge: true),
      );
    }

    final colRef = _db.collection('Users').doc(docId).collection('WatchItems');

    // Fetch existing Firestore items
    final snap = await colRef.get();
    final remoteIds = snap.docs.map((d) => d.id).toSet();
    final localIds  = localItems.map((i) => i.id).toSet();

    final toAdd    = localItems.where((i) => !remoteIds.contains(i.id)).toList();
    final toDelete = remoteIds.difference(localIds);

    if (toAdd.isEmpty && toDelete.isEmpty) return false;

    // Batch write — Firestore limit 500 ops per batch
    const chunkSize = 400;
    final allOps = <Future>[];

    for (var i = 0; i < toAdd.length; i += chunkSize) {
      final chunk = toAdd.sublist(i, (i + chunkSize).clamp(0, toAdd.length));
      final batch = _db.batch();
      for (final item in chunk) {
        batch.set(colRef.doc(item.id), {
          ...item.toFirestore(),
          'addedBy': username ?? '',
        });
      }
      allOps.add(batch.commit());
    }

    if (toDelete.isNotEmpty) {
      final batch = _db.batch();
      for (final id in toDelete) {
        batch.delete(colRef.doc(id));
      }
      allOps.add(batch.commit());
    }

    await Future.wait(allOps);
    return true;
  }

  // ── Fetch a friend's items by username ────────────────────────────────────
  static Future<List<WatchItem>> fetchFriendItems(String username) async {
    await ensureAuth();
    // Find user doc by username
    final userSnap = await _db.collection('Users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (userSnap.docs.isEmpty) return [];

    final docId = userSnap.docs.first.id;
    final itemsSnap = await _db
        .collection('Users')
        .doc(docId)
        .collection('WatchItems')
        .orderBy('viewedAt', descending: true)
        .get();

    return itemsSnap.docs
        .map((d) => WatchItem.fromMap(
              Map<String, dynamic>.from(d.data()),
              friendUsername: username,
            ))
        .toList();
  }

  // ── Check delta: local vs remote ───────────────────────────────────────────
  // Returns true if local has items not yet in Firestore
  static Future<bool> hasPendingChanges(List<WatchItem> localItems) async {
    final docId = await AppStorage.getDocId();
    if (docId == null) return localItems.isNotEmpty;

    final snap = await _db
        .collection('Users')
        .doc(docId)
        .collection('WatchItems')
        .get();

    final remoteIds = snap.docs.map((d) => d.id).toSet();
    final localIds  = localItems.map((i) => i.id).toSet();

    return localIds.difference(remoteIds).isNotEmpty ||
           remoteIds.difference(localIds).isNotEmpty;
  }
}
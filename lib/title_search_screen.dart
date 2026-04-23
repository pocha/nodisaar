import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'platform_badge.dart';

class TitleSearchResult {
  final String title;
  final String source;
  const TitleSearchResult(this.title, this.source);
}

class _TopPick {
  final String title;
  final String source;
  const _TopPick(this.title, this.source);
}

class TitleSearchScreen extends StatefulWidget {
  const TitleSearchScreen({super.key});

  @override
  State<TitleSearchScreen> createState() => _TitleSearchScreenState();
}

class _TitleSearchScreenState extends State<TitleSearchScreen> {
  static const _cacheKey = 'toppicks_cache';
  static const _url =
      'https://storage.googleapis.com/nodi-saar.firebasestorage.app/toppicks.json';

  final _ctrl = TextEditingController();
  List<_TopPick> _all = [];
  List<_TopPick> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
    _loadTopPicks();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadTopPicks() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      _parse(cached);
      if (mounted) setState(() => _loading = false);
      _fetch(prefs); // background refresh — non-blocking
    } else {
      await _fetch(prefs);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetch(SharedPreferences prefs) async {
    try {
      final resp = await http.get(Uri.parse(_url));
      if (resp.statusCode == 200) {
        await prefs.setString(_cacheKey, resp.body);
        _parse(resp.body);
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  void _parse(String json) {
    final list = jsonDecode(json) as List;
    _all = list
        .map((m) => _TopPick(
              m['title'] as String? ?? '',
              m['source'] as String? ?? '',
            ))
        .where((p) => p.title.isNotEmpty)
        .toList();
  }

  void _onChanged() {
    final q = _ctrl.text.trim();
    if (q.length < 3) {
      setState(() => _filtered = []);
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      _filtered =
          _all.where((p) => p.title.toLowerCase().contains(lower)).toList();
    });
  }

  void _select(TitleSearchResult result) => Navigator.pop(context, result);

  @override
  Widget build(BuildContext context) {
    final query = _ctrl.text.trim();
    final exactMatch =
        _filtered.any((p) => p.title.toLowerCase() == query.toLowerCase());
    final showAdd = query.length >= 3 && !exactMatch;

    return Scaffold(
      backgroundColor: const Color(0xFF0e0e11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0e0e11),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          enabled: !_loading,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: _loading ? 'Loading titles…' : 'Search titles…',
            hintStyle: const TextStyle(color: Color(0xFF7a7a8c)),
            border: InputBorder.none,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00a8e1)))
          : query.length < 3
              ? const Center(
                  child: Text('Type at least 3 characters',
                      style: TextStyle(
                          color: Color(0xFF7a7a8c), fontSize: 13)))
              : ListView(
                  children: [
                    ..._filtered.map((p) => ListTile(
                          leading: PlatformIcon(source: p.source, size: 36),
                          title: Text(p.title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                          subtitle: Text(labelForSource(p.source),
                              style: const TextStyle(
                                  color: Color(0xFF7a7a8c), fontSize: 12)),
                          onTap: () =>
                              _select(TitleSearchResult(p.title, p.source)),
                        )),
                    if (showAdd)
                      ListTile(
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00a8e1).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add,
                              color: Color(0xFF00a8e1), size: 20),
                        ),
                        title: Text('Add "$query"',
                            style: const TextStyle(
                                color: Color(0xFF00a8e1), fontSize: 14)),
                        onTap: () => _select(TitleSearchResult(query, '')),
                      ),
                  ],
                ),
    );
  }
}
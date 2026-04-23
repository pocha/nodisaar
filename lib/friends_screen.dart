import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'storage.dart';
import 'models.dart';
import 'platform_badge.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen> {
  List<_MergedItem> _items = [];
  bool _loading = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    reload();
  }

  void startLoading(String message) {
    if (mounted) setState(() { _loading = true; _loadingMessage = message; });
  }

  Future<void> reload() async {
    if (mounted) setState(() { _loading = true; _loadingMessage = ''; });
    try {
      final raw = await AppStorage.getAllFriendItems();
      if (mounted) setState(() => _items = _merge(raw));
    } finally {
      if (mounted) setState(() { _loading = false; _loadingMessage = ''; });
    }
  }

  List<_MergedItem> _merge(List<WatchItem> items) {
    final map = <String, _MergedItem>{};
    for (final item in items) {
      if (!map.containsKey(item.id)) {
        map[item.id] = _MergedItem(item);
      } else {
        map[item.id]!.merge(item);
      }
    }
    return map.values.toList()
      ..sort((a, b) => b.latestViewedAt.compareTo(a.latestViewedAt));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF00a8e1)),
            if (_loadingMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_loadingMessage,
                  style: const TextStyle(color: Color(0xFF7a7a8c), fontSize: 13)),
            ],
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('👥', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text("You're not following anyone",
                  style: TextStyle(fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 18, color: Colors.white)),
              SizedBox(height: 8),
              Text(
                "When a friend shares their Nodisaar link with you, "
                "open it to see their favourites here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7a7a8c), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF00a8e1),
      onRefresh: reload,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: _items.length,
        itemBuilder: (_, i) => _FriendItemTile(item: _items[i]),
      ),
    );
  }
}

// ── Merged item (same title across multiple friends) ──────────────────────────
class _MergedItem {
  final String title;
  final String href;
  final String source;
  final List<String> friendUsernames = [];
  DateTime latestViewedAt;

  _MergedItem(WatchItem w)
      : title = w.title,
        href = w.href,
        source = w.source,
        latestViewedAt = w.viewedAt {
    if (w.friendUsername != null) friendUsernames.add(w.friendUsername!);
  }

  void merge(WatchItem w) {
    if (w.friendUsername != null && !friendUsernames.contains(w.friendUsername)) {
      friendUsernames.add(w.friendUsername!);
    }
    if (w.viewedAt.isAfter(latestViewedAt)) latestViewedAt = w.viewedAt;
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────
class _FriendItemTile extends StatelessWidget {
  final _MergedItem item;
  const _FriendItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy').format(item.latestViewedAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2a2a33))),
      ),
      child: Row(
        children: [
          PlatformIcon(source: item.source),
          const SizedBox(width: 12),
          // Title + friend names
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(item.friendUsernames.join(', '),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF7a7a8c), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Latest viewed date
          Text(dateStr,
              style: const TextStyle(
                  color: Color(0xFF7a7a8c), fontSize: 12)),
        ],
      ),
    );
  }
}

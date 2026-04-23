class WatchItem {
  final String title;
  final String href;
  final String source;   // 'netflix' | 'prime'
  final DateTime viewedAt;  // parsed from DOM
  final DateTime addedAt;   // when user tapped Add
  final String? friendUsername; // set when fetched from a friend's doc

  WatchItem({
    required this.title,
    required this.href,
    required this.source,
    required this.viewedAt,
    required this.addedAt,
    this.friendUsername,
  });

  // Unique id matching Firestore watchItemId — title-based for cross-platform deduplication
  String get id => _slugify(title);

  static String _slugify(String s) =>
      s.toLowerCase()
       .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
       .replaceAll(RegExp(r'^_|_$'), '');

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'href': href,
    'source': source,
    'viewedAt': viewedAt.millisecondsSinceEpoch,
    'addedAt': addedAt.millisecondsSinceEpoch,
  };

  Map<String, dynamic> toLocal() => {
    'title': title,
    'href': href,
    'source': source,
    'viewedAt': viewedAt.millisecondsSinceEpoch,
    'addedAt': addedAt.millisecondsSinceEpoch,
    if (friendUsername != null) 'friendUsername': friendUsername,
  };

  factory WatchItem.fromMap(Map<String, dynamic> m, {String? friendUsername}) => WatchItem(
    title: m['title'] as String,
    href: m['href'] as String,
    source: m['source'] as String,
    viewedAt: DateTime.fromMillisecondsSinceEpoch(m['viewedAt'] as int),
    addedAt: DateTime.fromMillisecondsSinceEpoch(m['addedAt'] as int),
    friendUsername: friendUsername ?? m['friendUsername'] as String?,
  );
}
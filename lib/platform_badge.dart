import 'package:flutter/material.dart';

const Map<String, Color> _sourceColors = {
  'netflix':     Color(0xFFe50914),
  'prime':       Color(0xFF00a8e1),
  'jiohotstar':  Color(0xFF0f62ac),
  'appletv':     Color(0xFF555555),
  'max':         Color(0xFF002be7),
  'hulu':        Color(0xFF1ce783),
  'sonyliv':     Color(0xFF0033ff),
  'zee5':        Color(0xFF7b2d8b),
  'crunchyroll': Color(0xFFf47521),
  'paramount':   Color(0xFF0064ff),
  'mxplayer':    Color(0xFF00c3ff),
  'youtube':     Color(0xFFff0000),
  'discovery':   Color(0xFF0077c8),
};

const Map<String, String> _sourceAssets = {
  'netflix':     'assets/icon/netflix-logo.png',
  'prime':       'assets/icon/prime-logo.png',
  'jiohotstar':  'assets/icon/jiohotstar-logo.png',
  'appletv':     'assets/icon/appletv-logo.png',
  'max':         'assets/icon/max-logo.png',
  'hulu':        'assets/icon/hulu-logo.png',
  'sonyliv':     'assets/icon/sonyliv-logo.png',
  'zee5':        'assets/icon/zee5-logo.png',
  'crunchyroll': 'assets/icon/crunchyroll-logo.png',
  'paramount':   'assets/icon/paramount-logo.png',
  'mxplayer':    'assets/icon/mxplayer-logo.png',
  'youtube':     'assets/icon/youtube-logo.png',
  'discovery':   'assets/icon/discovery-logo.png',
};

const Map<String, String> _sourceLabels = {
  'netflix':     'Netflix',
  'prime':       'Prime Video',
  'jiohotstar':  'JioHotstar',
  'appletv':     'Apple TV+',
  'max':         'Max',
  'hulu':        'Hulu',
  'sonyliv':     'SonyLIV',
  'zee5':        'Zee5',
  'crunchyroll': 'Crunchyroll',
  'paramount':   'Paramount+',
  'mxplayer':    'MX Player',
  'youtube':     'YouTube Premium',
  'discovery':   'Discovery+',
};

Color colorForSource(String source) =>
    _sourceColors[source] ?? const Color(0xFF7a7a8c);

String? assetForSource(String source) => _sourceAssets[source];

String labelForSource(String source) =>
    _sourceLabels[source] ?? source;

class PlatformIcon extends StatelessWidget {
  final String source;
  final double size;
  const PlatformIcon({super.key, required this.source, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final color = colorForSource(source);
    final asset = assetForSource(source);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: asset != null
          ? Image.asset(asset, fit: BoxFit.contain)
          : Icon(Icons.tv, color: color, size: size * 0.6),
    );
  }
}
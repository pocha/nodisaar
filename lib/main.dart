import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_links/app_links.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const NodisaarApp());
}

class NodisaarApp extends StatefulWidget {
  const NodisaarApp({super.key});

  @override
  State<NodisaarApp> createState() => _NodisaarAppState();
}

class _NodisaarAppState extends State<NodisaarApp> {
  final _appLinks = AppLinks();
  String? _incomingFriend;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // App already open — listen for new links
    _appLinks.uriLinkStream.listen((uri) {
      final username = _extractUsername(uri);
      if (username != null && mounted) {
        setState(() => _incomingFriend = username);
      }
    });

    // App launched via deep link
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      final username = _extractUsername(initial);
      if (username != null) setState(() => _incomingFriend = username);
    }
  }

  String? _extractUsername(Uri uri) {
    // Handles: https://nodi-saar.github.io/user/<username>
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[segments.length - 2] == 'user') {
      return segments.last;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nodisaar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0e0e11),
        fontFamily: 'DM Sans',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00a8e1),
          secondary: Color(0xFFe50914),
        ),
      ),
      home: HomeScreen(incomingFriendUsername: _incomingFriend),
    );
  }
}
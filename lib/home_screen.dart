import 'package:flutter/material.dart';
import 'storage.dart';
import 'mypicks_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? incomingFriendUsername;
  const HomeScreen({super.key, this.incomingFriendUsername});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _myPicksKey = GlobalKey<MyPicksScreenState>();
  final _friendsKey = GlobalKey<FriendsScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.incomingFriendUsername != null) {
      _handleIncomingFriend(widget.incomingFriendUsername!);
    }
  }

  Future<void> _handleIncomingFriend(String username) async {
    await AppStorage.addFriendUsername(username);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.animateTo(1);
    });
  }

  Future<void> _onShareTapped() async {
    await _myPicksKey.currentState?.shareList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e0e11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0e0e11),
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFe50914), Color(0xFF00a8e1)],
          ).createShader(bounds),
          child: const Text('Nodisaar',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF7a7a8c)),
            tooltip: 'Share my picks',
            onPressed: _onShareTapped,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00a8e1),
          unselectedLabelColor: const Color(0xFF7a7a8c),
          indicatorColor: const Color(0xFF00a8e1),
          labelStyle: const TextStyle(
              fontFamily: 'Syne', fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'My Picks'),
            Tab(text: "Friends' Picks"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyPicksScreen(key: _myPicksKey),
          FriendsScreen(key: _friendsKey),
        ],
      ),
    );
  }
}
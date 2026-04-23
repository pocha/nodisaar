import 'package:flutter/material.dart';
import 'storage.dart';
import 'platform_badge.dart';

class WebViewDisclaimerScreen extends StatefulWidget {
  final String platform; // 'netflix' | 'prime'
  const WebViewDisclaimerScreen({super.key, required this.platform});

  @override
  State<WebViewDisclaimerScreen> createState() =>
      _WebViewDisclaimerScreenState();
}

class _WebViewDisclaimerScreenState extends State<WebViewDisclaimerScreen> {
  bool _dontShowAgain = false;

  String get _platformName => labelForSource(widget.platform);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e0e11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0e0e11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Before you continue',
          style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform header
            Row(
              children: [
                PlatformIcon(source: widget.platform, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Logging into $_platformName',
                    style: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _InfoCard(
              icon: Icons.public,
              iconColor: const Color(0xFF00a8e1),
              text:
                  'You\'re logging into $_platformName in a browser embedded within this app — the same as opening it in Safari or Chrome.',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFF2ecc71),
              text:
                  'Nodisaar does NOT capture or store your login credentials. Your username and password go directly to $_platformName.',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.devices_outlined,
              iconColor: const Color(0xFFf39c12),
              text:
                  'This web login does NOT count towards your $_platformName device limit. Only app or TV logins use a device slot.',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.notifications_none,
              iconColor: const Color(0xFF7a7a8c),
              text:
                  'You may receive a security notification from $_platformName about a new browser login. This is expected and safe to dismiss.',
            ),
            const SizedBox(height: 28),
            // Don't show again
            GestureDetector(
              onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
              child: Row(
                children: [
                  Checkbox(
                    value: _dontShowAgain,
                    onChanged: (v) =>
                        setState(() => _dontShowAgain = v ?? false),
                    activeColor: const Color(0xFF00a8e1),
                    side: const BorderSide(color: Color(0xFF7a7a8c)),
                  ),
                  const Text("Don't show this again",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00a8e1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  if (_dontShowAgain) await AppStorage.setWebViewDisclaimerOk();
                  nav.pop(true);
                },
                child: Text(
                  'Continue to $_platformName',
                  style: const TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  const _InfoCard(
      {required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17171c),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2a2a33)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFFc0c0cc), fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

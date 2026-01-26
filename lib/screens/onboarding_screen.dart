import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'username_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const _prefKey = 'onboarding_done';

  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardPage(
      title: 'Find Teammates Faster',
      subtitle: 'Join game rooms and connect with players instantly.',
      icon: Icons.sports_esports,
    ),
    _OnboardPage(
      title: 'Chat in Real Time',
      subtitle: 'Messages sync instantly with Firebase.',
      icon: Icons.chat_bubble_outline,
    ),
    _OnboardPage(
      title: 'Play Better Together',
      subtitle: 'Build a squad and start matching faster.',
      icon: Icons.groups_2_outlined,
    ),
  ];

  Future<void> _finish() async {
    await OnboardingScreen.markDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const UsernameScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: _pages,
              ),
            ),

            // Dots + buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  _Dots(count: _pages.length, index: _index),
                  const Spacer(),
                  if (!isLast)
                    FilledButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: _finish,
                      child: const Text('Get started'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(icon, size: 44),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/game_data.dart';
import '../models/game.dart';
import 'chat_screen.dart';

class GameListScreen extends StatelessWidget {
  const GameListScreen({super.key});

  void _openChat(BuildContext context, Game game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(game: game),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameMate'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final game = games[index];
          return _GameTile(
            game: game,
            onTap: () => _openChat(context, game),
          );
        },
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const _GameTile({
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Text(game.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class Game {
  final String id;
  final String name;
  final String subtitle; // örn: "5v5 • Ranked/Unrated"
  final String emoji;    // şimdilik icon yerine emoji kullanıyoruz

  const Game({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.emoji,
  });
}

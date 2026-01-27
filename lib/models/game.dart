import 'package:flutter/material.dart';

class Game {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;

  const Game({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}

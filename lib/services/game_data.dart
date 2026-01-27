import 'package:flutter/material.dart';
import '../models/game.dart';

const games = <Game>[
  Game(
    id: 'valorant',
    name: 'VALORANT',
    subtitle: 'Tactical shooter • Duo / Squad',
    icon: Icons.flash_on,
  ),
  Game(
    id: 'cs2',
    name: 'Counter-Strike 2',
    subtitle: 'Competitive FPS • Faceit / Premier',
    icon: Icons.gps_fixed,
  ),
  Game(
    id: 'lol',
    name: 'League of Legends',
    subtitle: 'MOBA • Ranked / Flex',
    icon: Icons.shield,
  ),
];

# GameMate 🎮

## Screenshots

<p float="left">
  <img src="assets/screenshots/game_list.png" width="240" />
  <img src="assets/screenshots/chat.png" width="240" />
</p>


GameMate is a Flutter-based mobile app that helps gamers find teammates via game-specific chat rooms.

## Current Features
- Choose a username (temporary session)
- Browse a list of popular multiplayer games
- Join game-specific chat rooms
- Send messages with an in-memory chat UI
- Separate chat state per game room
- Auto-scroll to the latest message

## Tech Stack
- Flutter + Dart
- In-memory state management
- Repository pattern (room-based storage)

## Project Structure
- `lib/models/` → Data models
- `lib/services/` → Session & repositories
- `lib/screens/` → UI screens

## Next Steps
- Firebase Authentication
- Realtime Database (rooms + messages)
- User presence / online status
- Push notifications

## Author
Umut Kunic

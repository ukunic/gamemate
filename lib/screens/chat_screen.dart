import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/user_session.dart';
import '../services/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final Game game;

  const ChatScreen({super.key, required this.game});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = ChatRepository.messagesFor(widget.game);

    // Room ilk kez açılıyorsa: örnek mesajlar (opsiyonel ama güzel)
    if (_messages.isEmpty) {
      _messages.addAll([
        const ChatMessage(user: 'Mert', text: 'Anyone duo?', time: '21:03'),
        const ChatMessage(user: 'Ece', text: 'Rank?', time: '21:04'),
      ]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _nowHHmm() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final username = UserSession.currentUser?.username ?? 'Unknown';

    setState(() {
      ChatRepository.addMessage(
        widget.game,
        ChatMessage(
          user: username,
          text: text,
          time: _nowHHmm(),
        ),
      );
    });

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final me = UserSession.currentUser?.username;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = (me != null) && (m.user == me);
                return _MessageBubble(message: m, isMe: isMe);
              },
            ),
          ),
          _Composer(
            controller: _controller,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.blue.withOpacity(0.25) : Colors.white.withOpacity(0.08);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          // Sadece diğer kullanıcıların adını göster
          if (!isMe)
            Text(
              message.user,
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
            ),
          if (!isMe) const SizedBox(height: 6),

          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Text(message.text),
          ),

          const SizedBox(height: 4),
          Text(
            message.time,
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Message…',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

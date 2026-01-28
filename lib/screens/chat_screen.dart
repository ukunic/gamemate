import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/game.dart';
import '../services/firestore_chat_repository.dart';
import '../services/user_session.dart';


class ChatScreen extends StatefulWidget {
  final Game game;

  const ChatScreen({super.key, required this.game});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  final _controller = TextEditingController();

  DateTime? _lastSentAt;

  final _repo = FirestoreChatRepository();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _hhmm(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (text.length > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message is too long (max 300).')),
      );
      return;
    }

    final user = UserSession.currentUser;
    if (user == null) return;

    // 🔒 anti-spam (2 saniye)
    final now = DateTime.now();
    if (_lastSentAt != null &&
        now.difference(_lastSentAt!).inSeconds < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slow down 🙂')),
      );
      return;
    }

    await _repo.sendMessage(
      gameId: widget.game.id,
      userId: user.uid,
      username: user.username,
      text: text,
    );

    _lastSentAt = now; // 👈 bunu ekliyoruz

    _controller.clear();
    FocusScope.of(context).unfocus();
    _scrollToBottom();
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _repo.watchMessages(widget.game.id, limit: 60),
              builder: (context, snapshot) {
                final myUid = UserSession.currentUser?.uid;
                final messages = snapshot.data ?? [];

                // yeni mesaj gelince en alta kay
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ChatLoading();
                }


                if (messages.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 42),
                          const SizedBox(height: 14),
                          const Text(
                            'No messages yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Be the first to start the conversation 👋',
                            style: TextStyle(color: Colors.white.withOpacity(0.65)),
                          ),
                        ],
                      ),
                    ),
                  );
                }


                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = (myUid != null) && (m.userId == myUid);
                    return _MessageBubble(
                      message: m,
                      isMe: isMe,
                      timeText: _hhmm(m.createdAt),
                    );
                  },
                );
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
  final String timeText;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.timeText,
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
          if (!isMe)
            Text(
              message.username,
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
            timeText,
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function() onSend;

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
                  hintText: 'Type a message…',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              onPressed: () => onSend(),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatLoading extends StatelessWidget {
  const _ChatLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }
}


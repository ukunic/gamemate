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

    final user = UserSession.currentUser;
    if (user == null) return; // username ekranından gelinmiyorsa güvenlik

    await _repo.sendMessage(
      gameId: widget.game.id,
      message: ChatMessage(
        userId: user.uid,
        username: user.username,
        text: text,
        createdAt: DateTime.now(),
      ),
    );

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
    final myUid = UserSession.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _repo.watchMessages(widget.game.id),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                // yeni mesaj gelince en alta kay
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hi 👋',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                  );
                }

                return ListView.builder(
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
              onPressed: () => onSend(),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

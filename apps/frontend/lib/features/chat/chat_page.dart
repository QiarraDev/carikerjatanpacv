import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket _socket;
  final _messageController = TextEditingController();
  final List<String> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io('http://10.0.2.2:3000', IO.OptionBuilder().setTransports(['websocket']).build());
    _socket.onConnect((_) => print('--- Connected to Chat WebSocket'));
    _socket.on('message', (data) {
      if (mounted) {
        setState(() {
          final msg = data.toString();
          if (msg.startsWith("Me:") || msg.startsWith("HR Bot:")) {
            if (msg.startsWith("HR Bot:")) _isTyping = false;
            _messages.add(msg);
          } else {
            _messages.add("HR: $msg");
          }
        });
      }
    });

    // Simulasi typing (ini bisa ditingkatkan dengan event socket 'typing' sungguhan)
    _socket.on('message', (data) {
      if (data.toString().startsWith("Me:") && mounted) {
        setState(() => _isTyping = true);
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final msg = "Me: ${_messageController.text}";
      _socket.emit('message', msg);
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HR Team'),
            Text('Online', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.startsWith("Me:");
                final cleanMsg = msg.replaceFirst("Me: ", "").replaceFirst("HR Bot: ", "").replaceFirst("HR: ", "");
                
                return _buildChatBubble(cleanMsg, isMe);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                   Text('HR sedang mengetik', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                   SizedBox(width: 4),
                   SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              gradient: isMe 
                  ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)])
                  : null,
              color: isMe ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : const Color(0xFF1E293B), fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
            child: Text(
              isMe ? 'Sent' : 'Read',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan Anda...',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF6366F1),
              radius: 24,
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

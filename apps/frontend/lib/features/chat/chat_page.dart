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
  final List<String> _messages = ["HR: Halo! Saya melihat video profile Anda.", "HR: Sangat menarik. Apakah bersedia interview?"];

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io('http://10.0.2.2:3000', IO.OptionBuilder().setTransports(['websocket']).build());
    _socket.onConnect((_) => print('--- Connected to Chat WebSocket'));
    _socket.on('message', (data) {
      setState(() => _messages.add("Stranger: $data"));
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _socket.emit('message', _messageController.text);
      setState(() => _messages.add("Me: ${_messageController.text}"));
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat dengan HR'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isMe = _messages[index].startsWith("Me:");
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF6366F1) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index],
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Ketik pesan...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24))),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Color(0xFF6366F1))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

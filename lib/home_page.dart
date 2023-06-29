import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToServer();
  }
  void connectToServer() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.on('chat_message', (data) {
      setState(() {
        messages.add(data);
      });
    });
  }
  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      print("sent");
      socket.emit('chat_message', message);
      print(message);
      messageController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Socket.IO Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
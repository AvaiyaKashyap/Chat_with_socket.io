import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_test/chat_controller.dart';

import 'message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late IO.Socket socket;
  TextEditingController msgInputController = TextEditingController();
  ChatController chatController = ChatController();
  @override
  void initState() {
    socket = IO.io('http://localhost:4000');
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build();
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          Expanded(
            flex: 9,
            child: Obx(
                () => ListView.builder(
                  itemCount: chatController.chatMessage.length,
                  itemBuilder: (context, index) {
                    var currentItem = chatController.chatMessage[index];
                    return MessageItem(
                      sentByMe: currentItem.sentByMe == socket.id,
                      Message: currentItem.message,
                    );
                  }),
            ),
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.deepPurple[300],
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: msgInputController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      sendMessage(msgInputController.text);
                      msgInputController.text = "";
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ))
        ],
      )),
    );
  }

  void sendMessage(String text) {
    var messageJson = {"message": text,"sentByMe": socket.id};
    socket.emit("message", messageJson);
    chatController.chatMessage.add(Message.fromJson(messageJson));

    // print(messageJson);
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatMessage.add(Message.fromJson(data));
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.sentByMe, required this.Message});
  final bool sentByMe;
  final String Message;
  @override
  Widget build(BuildContext context) {
    Color purple = Color(0xff6c5ce7);
    Color black = Color(0xff191919);
    Color white = Colors.white;
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          color: sentByMe ? purple : white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Message, style: TextStyle(
                  fontSize: 18, color: sentByMe ? Colors.white : Colors.purple),),
            SizedBox(
              width: 5,
            ),
            Text(
              "2:38 PM",
              style: TextStyle(
                fontSize: 10,
                color:
                    (sentByMe ? Colors.white : Colors.purple).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

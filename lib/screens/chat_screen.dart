import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/chat_model.dart';

import '../models/post_model.dart';
import '../widgets/message_list_tile.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _message = "";

  late TextEditingController _textEditingController;

  final currentUserId =  FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Post post = ModalRoute.of(context)!.settings.arguments as Post;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(post.id)
                    .collection("comments").orderBy("timeStamp")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.hasError.toString()),
                    );
                  }

                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        final QueryDocumentSnapshot doc =
                            snapshot.data!.docs[index];

                        final ChatModel chatModel = ChatModel(
                          timestamp: doc["timeStamp"],
                          username: doc["username"],
                          userId: doc["userId"],
                          message: doc["message"],
                        );

                        return Align(
                          //Отображение сообщений
                          alignment: chatModel.userId ==
                              currentUserId
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: MessageListTile(chatModel),
                        ); // Выводим сообщения
                      });
                },
              ),
            ),
            Container(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _textEditingController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Enter message",
                      ),
                      onChanged: (value) {
                        _message = value;
                      },
                    ),
                  )),
                  IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("posts")
                          .doc(post.id)
                          .collection("comments")
                          .add({
                            "userId": FirebaseAuth.instance.currentUser!.uid,
                            "username":
                                FirebaseAuth.instance.currentUser!.displayName,
                            "message": _message,
                            "timeStamp": Timestamp.now(),
                          })
                          .then((value) => print("chat doc added"))
                          .catchError((onError) => print(
                              "Error has occeured while adding chat doc"));

                      _textEditingController.clear();
                      setState(() {
                        _message = "";
                      });
                    },
                    icon: Icon(Icons.arrow_circle_right),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

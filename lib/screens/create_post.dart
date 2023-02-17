import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as fires;

class CreatePost extends StatefulWidget {
  static const String id = "create_post";
  const CreatePost({Key? key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  late String imageUrl;

  String _description = "";


  Future<void> _submit({required File image}) async{
    FocusScope.of(context).unfocus();

    if (_description.trim().isNotEmpty) {
      //1. write image to storage
      fires.FirebaseStorage storage = fires.FirebaseStorage.instance; // Создание экземпляра

      //Загружаем файл, получаем ссылку
      await storage.ref("images/${UniqueKey().toString()}.png").putFile(image).then((taskSnapshot) async {
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      });
    }

    FirebaseFirestore.instance.collection("posts").add({
      "timestamp" : Timestamp.now(),
      "userId" : FirebaseAuth.instance.currentUser!.uid,
      "username" : FirebaseAuth.instance.currentUser!.displayName,
      "urlImage" : imageUrl,
      "description" : _description,
    }).then((docRef) => docRef.update({"postId" : docRef.id}));

    Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    final File imageFile = ModalRoute.of(context)!.settings.arguments as File;

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(imageFile),
                        fit: BoxFit.cover,
                      )
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 1.4,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter a description ",
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(180), //Указываем скольско символов можно ввести
                  ],
                  onChanged: (value) {
                    _description = value;
                  },

                  onEditingComplete: (){
                    _submit(image: imageFile);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

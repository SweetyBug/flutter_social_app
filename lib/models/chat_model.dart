import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String username;
  final String userId;
  final String message;
  final Timestamp timestamp;

  ChatModel(
      {required this.timestamp,
      required this.username,
      required this.userId,
      required this.message});
}

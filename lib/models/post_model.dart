import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final Timestamp timestamp;
  final String urlImage;
  final String description;

  Post({
    required this.id,
    required this.username,
    required this.userId,
    required this.timestamp,
    required this.urlImage,
    required this.description,
  });
}
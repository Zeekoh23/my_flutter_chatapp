import 'package:flutter/foundation.dart';

class Chat with ChangeNotifier {
  String? id;
  String? name;
  String? email;
  String? number;
  String? about;
  String? lastMessage;
  String? image;
  int? quantity;
  String? time;
  bool? isActive;
  String? userid;
  DateTime? createdAt;
  Chat(
      {this.id,
      this.name,
      this.email,
      this.number,
      this.about,
      this.lastMessage,
      this.image,
      this.time,
      this.isActive,
      this.userid,
      this.quantity,
      this.createdAt});
}

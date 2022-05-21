import 'package:flutter/foundation.dart';

enum UserMode { Signup, Login }

class UserItem with ChangeNotifier {
  final String? userid;
  String? name;
  final String? email;
  String? number;
  final String? image;
  String? about;
  final String? password;
  final String? passwordConfirm;
  final String? token;
  final DateTime? expiryDate;

  UserItem(
      {this.userid,
      this.email,
      this.name,
      this.number,
      this.image,
      this.about,
      this.password,
      this.passwordConfirm,
      this.expiryDate,
      this.token});
}

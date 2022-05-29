import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../helpers/socket_helper.dart';
import '../models/http_exception.dart';
import '../models/user_model.dart';
import '../helpers/url_helper.dart';

class UserProvider with ChangeNotifier {
  var socket = SocketHelper.shared;
  var baseurl = UrlHelper.shared;
  var log = Logger();
  late String _token;
  DateTime? _expiryDate;
  late String _userId;
  Timer? _authTimer;
  late String _email;
  late String _name;
  late String _number;
  late String _image;
  late String _about;

  List<UserItem> _items = [];

  List<UserItem> get items {
    return [..._items];
  }

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != '') {
      log.i(_token);
      return _token;
    }
    return '';
  }

  String get userId {
    return _userId;
  }

  String get email {
    return _email;
  }

  String get number {
    return _number;
  }

  String get name {
    return _name;
  }

  String get image {
    return _image;
  }

  String get about {
    return _about;
  }

  Future<void> fetchUsers() async {
    try {
      final url = Uri.parse('${baseurl.baseUrl}/api/v1/users?_id[ne]=$userId');

      final res = await http.get(url);
      final extractData = json.decode(res.body) as Map<String, dynamic>;

      final List<UserItem> loadUsers = [];
      extractData.forEach((id, userData) {
        loadUsers.add(UserItem(
          userid: userData['_id'],
          name: userData['name'],
          email: userData['email'],
          number: userData['number'],
          image: userData['image'],
          about: userData['about'],
        ));
      });

      log.i(extractData);
      _items = loadUsers;
      notifyListeners();
    } catch (err) {
      throw HttpException('fetch user error is $err');
    }
  }

  Future<void> updateUser(UserItem user) async {
    try {
      var url = Uri.parse("${baseurl.baseUrl}/api/v1/users/$userId");
      final headers = {"Content-type": "application/json"};
      final res = await http.post(url,
          headers: headers,
          body: json.encode({
            'name': user.name,
            'about': user.about,
          }));

      final resData = json.decode(res.body);

      log.i(resData);

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'image': image,
        'name': user.name,
        'about': user.about,
        'number': _number,
        'email': _email,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);

      final extractData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

      final expiryDate = DateTime.parse(extractData['expiryDate'] as String);
      _token = extractData['token'];
      _userId = extractData['userId'];
      _image = extractData['image'];
      _name = extractData['name'];
      _about = extractData['about'];
      _number = extractData['number'];
      _email = extractData['email'];
      _expiryDate = expiryDate;

      notifyListeners();
    } catch (err) {
      throw HttpException('update user error is $err');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      var url = Uri.parse("${baseurl.baseUrl}/api/v1/users/forgotpassword");
      final headers = {"Content-type": "application/json"};
      final res = await http.put(url,
          headers: headers, body: json.encode({'email': email}));

      final resData = json.decode(res.body) as Map<String, dynamic>;
      if (resData['message'] != null) {
        throw HttpException(resData['message']);
      }
      log.i(resData);
      notifyListeners();
    } catch (err) {
      throw HttpException('forgot password error is $err');
    }
  }

  Future<void> updateProfilePic(String image, BuildContext context) async {
    try {
      for (int i = 0; i < socket.msgController.popUp.value; i++) {
        Navigator.pop(context);
      }
      socket.msgController.popUp.value = 0;

      var url = Uri.parse('${baseurl.baseUrl}/api/v1/users/$userId');
      final headers = {"Content-type": "application/json"};
      final res = await http.post(url,
          headers: headers, body: json.encode({'image': image}));
      final resData = json.decode(res.body);
      log.i(resData);

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'image': image,
        'name': _name,
        'about': _about,
        'number': _number,
        'email': _email,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);

      final extractData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

      final expiryDate = DateTime.parse(extractData['expiryDate'] as String);
      _token = extractData['token'];
      _userId = extractData['userId'];
      _image = extractData['image'];
      _name = extractData['name'];
      _about = extractData['about'];
      _number = extractData['number'];
      _email = extractData['email'];
      _expiryDate = expiryDate;

      notifyListeners();
    } catch (err) {
      throw HttpException('update profile error is $err');
    }
  }

  Future<void> fetchProfile() async {
    try {
      final url = Uri.parse('${baseurl.baseUrl}/api/v1/users/$userId');
      final res = await http.get(url);
      final extractData = json.decode(res.body) as Map<String, dynamic>;

      final List<UserItem> loadUsers = [];
      extractData.forEach((id, userData) {
        loadUsers.add(UserItem(
          userid: id,
          name: userData['name'],
          email: userData['email'],
          number: userData['number'],
          image: userData['image'],
          about: userData['about'],
        ));
      });

      log.i(extractData);
      _items = loadUsers;
      notifyListeners();
    } catch (err) {
      throw HttpException('fetch profile error is $err');
    }
  }

  Future<void> login(String number, String password) async {
    final url = Uri.parse('${baseurl.baseUrl}/api/v1/users/login');
    try {
      final headers = {"Content-type": "application/json"};

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'number': number,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      if (responseData['message'] != null) {
        throw HttpException(responseData['message'] as String);
      }

      _token = responseData['token'];
      _image = responseData['data']['user']['image'];
      _about = responseData['data']['user']['about'];
      _name = responseData['data']['user']['name'];
      _userId = responseData['data']['user']['_id'];
      _email = responseData['data']['user']['email'];
      _number = responseData['data']['user']['number'];
      /*_expiryDate = DateTime.now().add(
      Duration(seconds: int.parse(responseData['expiresin'])),
    );*/
      _expiryDate = DateTime.now().add(
        const Duration(seconds: 6000000),
      );

      log.i(responseData);
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'image': _image,
        'name': _name,
        'about': _about,
        'number': _number,
        'email': _email,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
      //throw HttpException('login error is $error');
    }
  }

  Future<void> signup(String name, String email, String number, String password,
      String passwordConfirm, String about) async {
    try {
      final url = Uri.parse('${baseurl.baseUrl}/api/v1/users/signup');
      final headers = {"Content-type": "application/json"};
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            'name': name,
            'email': email,
            'number': number,
            'about': about,
            'password': password,
            'passwordConfirm': passwordConfirm
          }));

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['message'] != null) {
        throw HttpException(responseData['message']);
      }

      _token = responseData['token'];
      _image = responseData['data']['user']['image'];
      _about = responseData['data']['user']['about'];
      _name = responseData['data']['user']['name'];
      _userId = responseData['data']['user']['_id'];
      _email = responseData['data']['user']['email'];
      _number = responseData['data']['user']['number'];
      /*_expiryDate = DateTime.now().add(
      Duration(seconds: int.parse(responseData['expiresin'])),
    );*/
      _expiryDate = DateTime.now().add(
        const Duration(seconds: 6000000),
      );

      log.i(responseData);
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'image': _image,
        'name': _name,
        'about': _about,
        'number': _number,
        'email': _email,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (err) {
      throw err;
      //throw HttpException('signup error is $err');
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }

      final extractedData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      log.i(extractedData);

      final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);

      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = extractedData['token'];
      _userId = extractedData['userId'];
      _name = extractedData['name'];
      _number = extractedData['number'];
      _image = extractedData['image'];
      _about = extractedData['about'];
      _email = extractedData['email'];
      _expiryDate = expiryDate;

      notifyListeners();
      _autoLogout();
      return true;
    } catch (err) {
      throw HttpException('autologinerror is $err');
    }
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}

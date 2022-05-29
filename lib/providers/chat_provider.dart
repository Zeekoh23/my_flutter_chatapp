import 'dart:convert';

import 'package:chat_easy/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../helpers/url_helper.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class ChatProvider with ChangeNotifier {
  var log = Logger();
  var baseurl = UrlHelper.shared;

  List<Chat> _items = [];

  Map<String, Chat> _items1 = {};

  final String userid;
  final String name;
  final String number;
  final String email;
  final String image;
  final String aboutus;

  ChatProvider(this.userid, this.name, this.number, this.email, this.image,
      this.aboutus, this._items);

  //chat list
  List<Chat> get items {
    return [..._items];
  }

  //chat map
  Map<String, Chat> get items1 {
    return {..._items1};
  }

  //fetch chats
  Future<void> fetchChats() async {
    try {
      var url = Uri.parse(
          '${baseurl.baseUrl}/api/v1/chats?sort=-createdAt&userid=$number');
      final res = await http.get(url);
      final extractData = json.decode(res.body) as Map<String, dynamic>;

      final List<Chat> loadChats = [];
      extractData.forEach((id, chatData) {
        loadChats.add(Chat(
            id: chatData['_id'],
            name: chatData['name'],
            number: chatData['number'],
            email: chatData['email'],
            image: chatData['image'],
            about: chatData['about'],
            lastMessage: chatData['lastMessage'],
            time: chatData['time'],
            quantity: chatData['quantity'],
            userid: chatData['userid'],
            createdAt: DateTime.parse(chatData['createdAt'])));
      });
      log.i(extractData);
      _items = loadChats;
      notifyListeners();
    } catch (error) {
      throw HttpException('Fetch Chat Error is $error');
    }
  }

  //create chats
  Future<void> createChat(
    UserItem user,
    String message,
    String time,
  ) async {
    try {
      final headers = {"Content-type": "application/json"};
      late String id1;
      late String id2;

      var user1 = Chat(
          name: '',
          email: '',
          about: '',
          number: '',
          lastMessage: '',
          quantity: 1,
          image: '',
          time: '',
          userid: '');

      //checks if the chat number exist
      if (_items1.containsKey(number)) {
        //update that particular chat using the existing number
        _items1.update(
            number,
            (chat) => Chat(
                  name: name,
                  email: email,
                  number: number,
                  about: aboutus,
                  lastMessage: message = message,
                  quantity: user1.quantity = chat.quantity! + 1,
                  image: image,
                  time: time = time,
                  userid: user.number,
                ));

        var url2 = Uri.parse('${baseurl.baseUrl}/api/v1/chats/number/$number');
        final ress1 = await http.get(url2, headers: headers);
        final extractData2 = json.decode(ress1.body);
        //initialize the declared variable id with extractData2
        id2 = extractData2['data']['query']['_id'];
        log.i(id2);

        var url3 = Uri.parse('${baseurl.baseUrl}/api/v1/chats/$id2');

        final res1 = await http.post(url3,
            headers: headers,
            body: json.encode({
              'lastMessage': message,
              'time': time,
              'quantity': user1.quantity
            }));
        final resData1 = json.decode(res1.body);
        log.i(resData1);
      } else if (_items1.containsKey(user.number)) {
        _items1.update(
            user.number!,
            (chat) => Chat(
                name: user.name,
                email: user.email,
                about: user.about,
                number: user.number,
                lastMessage: message,
                image: user.image,
                time: time,
                userid: number));
        //the url to get the number of the user
        var urlnumber =
            Uri.parse('${baseurl.baseUrl}/api/v1/chats/number/${user.number}');
        final ress = await http.get(urlnumber, headers: headers);
        final extractData1 = json.decode(ress.body);
        id1 = extractData1['data']['query']['_id'];
        log.i(id1);

        var url1 = Uri.parse('${baseurl.baseUrl}/api/v1/chats/$id1');

        final res = await http.post(url1,
            headers: headers,
            body: json.encode({
              'lastMessage': message,
              'time': time,
            }));
        final resData = json.decode(res.body);
        log.i(resData);
      } else {
        //creates new chats for the logged in user and the person he is sending message to
        final url = Uri.parse('${baseurl.baseUrl}/api/v1/chats');

        _items1.putIfAbsent(
            number,
            () => Chat(
                name: name,
                email: email,
                number: number,
                about: aboutus,
                quantity: 1,
                lastMessage: message,
                image: image,
                time: time,
                userid: user.number));

        final response1 = await http.post(url,
            headers: headers,
            body: json.encode({
              'name': name,
              'email': email,
              'number': number,
              'about': aboutus,
              'quantity': 1,
              'lastMessage': message,
              'image': image,
              'time': time,
              'userid': user.number,
            }));

        final resData3 = json.decode(response1.body);
        log.i(resData3);

        _items1.putIfAbsent(
            user.number!,
            () => Chat(
                name: user.name,
                email: user.email,
                about: user.about,
                number: user.number,
                lastMessage: message,
                quantity: 0,
                image: user.image,
                time: time,
                userid: number));

        final response = await http.post(url,
            headers: headers,
            body: json.encode({
              'name': user.name,
              'email': user.email,
              'number': user.number,
              'about': user.about,
              'lastMessage': message,
              'quantity': 0,
              'image': user.image,
              'time': time,
              'userid': number,
            }));
        final resDat2 = json.decode(response.body);
        log.i(resDat2);
      }

      notifyListeners();
    } catch (err) {
      throw HttpException('Create or Update Chat Error is $err');
    }
  }

  Future<void> updateChat(Chat chat, String message, String time) async {
    try {
      late String id;
      late int quantity;

      final headers = {"Content-type": "application/json"};
      var url = Uri.parse("${baseurl.baseUrl}/api/v1/chats/${chat.id}");
      final res = await http.post(url,
          headers: headers,
          body: json.encode({
            'lastMessage': message,
            'time': time,
          }));

      final resData = json.decode(res.body);
      log.i(resData);

      //to get a chat of the logged in user
      var url2 = Uri.parse('${baseurl.baseUrl}/api/v1/chats/number/$number');
      final ress1 = await http.get(url2, headers: headers);
      final extractData2 = json.decode(ress1.body);
      id = extractData2['data']['query']['_id'];
      quantity = extractData2['data']['query']['quantity'];
      log.i(id);

      var url1 = Uri.parse("${baseurl.baseUrl}/api/v1/chats/$id");
      final res1 = await http.post(url1,
          headers: headers,
          body: json.encode({
            'lastMessage': message,
            'time': time,
            'quantity': quantity + 1
          }));
      final resData1 = json.decode(res1.body);
      log.i(resData1);
    } catch (err) {
      throw HttpException('Update Chat Error is $err');
    }
  }

  Future<void> updateChatProperty(String params, String body) async {
    try {
      final headers = {"Content-type": "application/json"};

      var url = Uri.parse("${baseurl.baseUrl}/api/v1/chats/$params/$email");

      final res = await http.post(url,
          headers: headers,
          body: json.encode({
            params: body,
          }));
      log.i(body);
      final resData = json.decode(res.body);
      log.i(resData);
    } catch (err) {
      throw HttpException('Update chat property error is $err');
    }
  }

  Future<void> updateChatImage(String imageUpdate) async {
    String image = 'image';
    await updateChatProperty(image, imageUpdate);
  }

  Future<void> updateChatAbout(String aboutUpdate) async {
    String about = 'about';
    await updateChatProperty(about, aboutUpdate);
  }

  Future<void> updateChatName(String nameUpdate) async {
    String name = 'name';
    await updateChatProperty(name, nameUpdate);
  }

  Future<void> updateChatQuantity(Chat chat) async {
    try {
      final headers = {"Content-type": "application/json"};
      var url = Uri.parse("${baseurl.baseUrl}/api/v1/chats/${chat.id}");

      final res = await http.post(url,
          headers: headers,
          body: json.encode({
            'quantity': 0,
          }));
      final resData = json.decode(res.body);
      log.i(resData);
    } catch (err) {
      throw HttpException('Update Chat Quantity is $err');
    }
  }
}

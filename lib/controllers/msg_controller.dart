import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../models/message_model.dart';
import '../widgets/individual_card.dart';
import '../providers/message_provider.dart';
import '../models/push_notification.dart';

class MsgController extends GetxController {
  //this variables are declared globally to be accessed through this class
  var messages1 = <Message>[].obs;
  //var individual1 = IndividualCard.individual;
  /* MsgController({this.context, this.number, this.source});
  BuildContext? context;
  String? number;
  String? source;*/
  //var indiState = IndividualCardState.inCardState;

  var loadMessages =
      <Message>[].obs; //this variable when used will hold the messages fetched

  var notificationInfo = <PushNotification>[].obs;
  /*Future<void> fetchMessages() async {
    await Provider.of<MessageProvider>(context!, listen: false)
        .fetchMessages(source!, number!);
  }*/
  /* Future<void> fetchMessages() async {
    await Provider.of<MessageProvider>(indiState.context, listen: false)
        .fetchMessages(indiState.source, indiState.widget.chat!.number!);
  }*/

  @override
  void onInit() {
    super.onInit();
    //fetchMessages();
  }

  @override
  void onClose() {
    super.onClose();
    //fetchMessages();
  }

  var popUp = 0.obs;
  var isRecording = false.obs;
  var typing = false.obs;
  var isGallery = false.obs;
  var isFile = false.obs;
  var show = false.obs;
  var sendbutton = false.obs;
  var isVideoGallery = false.obs;
  var profilePage = false.obs;
  var httpExist = false.obs;
  var totalNotificationCounter = 0.obs;
}

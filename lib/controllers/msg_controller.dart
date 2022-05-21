import 'package:get/get.dart';

import '../models/message_model.dart';
import '../models/push_notification.dart';

class MsgController extends GetxController {
  //this variables are declared globally to be accessed through this class
  var messages1 = <Message>[].obs;
  var loadMessages =
      <Message>[].obs; //this variable when used will hold the messages fetched

  var notificationInfo = <PushNotification>[].obs;

  var popUp = 0.obs;
  var isRecording = false.obs;
  var typing = false.obs;
  var isGallery = false.obs;
  var isFile = false.obs;
  var isVideoGallery = false.obs;
  var profilePage = false.obs;
  var httpExist = false.obs;
  var totalNotificationCounter = 0.obs;
}

import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:path_provider/path_provider.dart';

import './cameraview_screen.dart';
import '../controllers/msg_controller.dart';
import './videoview_screen.dart';
import '../widgets/videorecord_timer.dart';
import '../helpers/socket_helper.dart';
import '../models/chat_model.dart';
import '../widgets/blinking_button.dart';
import '../models/user_model.dart';

late List<CameraDescription> cam;

class CameraScreen extends StatefulWidget {
  CameraScreen({Key? key, this.destination, this.user, this.chat})
      : super(key: key);
  String? destination;
  Chat? chat;
  UserItem? user;

  static const routename = '/camera';

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  MsgController msgController = MsgController();
  String videoPath = '';
  bool isRecording = false;
  bool flash = false;

  var socket = SocketHelper.shared;
  //var isrecording = socket.msgController.isRecording.value;

  bool isCameraFront = true;
  double transform = 0;
  late Future<void> cameravalue;
  int _selectedIndex = 0;
  late List<Widget> differentButton;
  bool _isHours = true;
  bool singleTap = true;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countUp,
      onChange: (value) => print('onChange $value'),
      onChangeRawSecond: (val) => print('onChangeRawSecond $val'),
      onChangeRawMinute: (val) => print('onChangeRawMinute $val'),
      onStop: () {
        print('onStop');
      },
      onEnded: () {
        print('onEnded');
      });

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(cam[0], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420);
    cameravalue = _cameraController.initialize();

    differentButton = [cameraButton(), videoButton()];
    _stopWatchTimer.rawTime.listen(
        (val) => print('rawTime $val ${StopWatchTimer.getDisplayTime(val)}'));
    _stopWatchTimer.records.listen((val) => print('records $val'));
    _stopWatchTimer.fetchStop.listen((val) => print('stop from stream'));
    _stopWatchTimer.fetchEnded.listen((val) => print('ended from stream'));
  }

  @override
  void dispose() async {
    super.dispose();
    _cameraController.dispose();
    await _stopWatchTimer.dispose();
  }

  Future<void> takePhoto() async {
    await cameravalue;
    String path1 = path.join(
        (await getTemporaryDirectory()).path, '${DateTime.now()}.png');

    final image = await _cameraController.takePicture();
    socket.msgController.isFile.value = true;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => CameraViewScreen(
                path: image.path,
                destination: widget.destination,
                chat: widget.chat,
                user: widget.user)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _selectedIndex,
      child: Scaffold(
        appBar: AppBar(title: const Text('Camera Screen'), centerTitle: true),
        body: Stack(children: [
          FutureBuilder(
              future: cameravalue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(children: [
                      const SizedBox(height: 10),
                      CameraPreview(_cameraController),
                      socket.msgController.isRecording.value
                          ? VideoRecordTimer(
                              stopWatchTimer: _stopWatchTimer,
                              isHours: _isHours,
                            )
                          : SizedBox(),
                    ]),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          Positioned(
              bottom: 0.0,
              child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: [
                    TabBar(
                      indicatorColor: Colors.white,
                      onTap: (val) {
                        setState(() {
                          _selectedIndex = val;
                        });
                      },
                      tabs: const [
                        Tab(
                          text: 'Camera',
                        ),
                        Tab(text: 'Video'),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      width: MediaQuery.of(context).size.width,
                      child: differentButton[_selectedIndex],
                    )
                  ]))),
        ]),
      ),
    );
  }

  Widget cameraButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        flashMode(),
        GestureDetector(
            onTap: () {
              takePhoto();
            },
            child: const Icon(Icons.radio_button_on,
                color: Colors.white, size: 70)),
        switchCamera(),
      ],
    );
  }

  Widget videoButton() {
    return Column(children: [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          flashMode(),
          GestureDetector(
            onTap: () async {
              /* String path2 = path.join((await getTemporaryDirectory()).path,
                    '${DateTime.now()}.mp4');*/
              socket.msgController.isRecording.value = true;
              await _cameraController.startVideoRecording();

              _stopWatchTimer.onExecute.add(StopWatchExecute.start);

              if (singleTap) {
                setState(() {
                  singleTap = false;
                });
              }

              /* setState(() {
                  videoPath = path2;
                });*/
            },
            onLongPress: () async {
              socket.msgController.isFile.value = true;
              socket.msgController.isVideoGallery.value = false;
              final video = await _cameraController.stopVideoRecording();
              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

              await cameravalue;

              final image = await _cameraController.takePicture();

              /*setState(() {
                  isRecording = false;
                });*/
              socket.msgController.isRecording.value = false;

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => VideoViewScreen(
                          videoPath: video.path,
                          path: image.path,
                          destination: widget.destination,
                          chat: widget.chat,
                          user: widget.user)));
            },
            child: socket.msgController.isRecording.value
                ? Container(
                    child: const Icon(Icons.crop_square_outlined,
                        color: Colors.red, size: 80),
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                        color: Colors.red,
                        blurRadius: 5.0,
                        spreadRadius: 20.0,
                      ),
                    ]),
                  )
                : const Icon(Icons.crop_square_outlined,
                    color: Colors.white, size: 80),
          ),
          switchCamera(),
        ],
      ),
      const SizedBox(height: 10),
      const Text(
        'Tap to Video, Hold to Stop Video',
        textAlign: TextAlign.center,
      ),
    ]);
  }

  IconButton flashMode() {
    return IconButton(
      onPressed: () {
        setState(() {
          flash = !flash;
        });
        flash
            ? _cameraController.setFlashMode(FlashMode.torch)
            : _cameraController.setFlashMode(FlashMode.off);
      },
      icon: Icon(
        flash ? Icons.flash_on : Icons.flash_off,
        size: 28,
      ),
    );
  }

  IconButton switchCamera() {
    return IconButton(
        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
        onPressed: () {
          setState(() {
            isCameraFront = !isCameraFront;
            transform = transform + pi;
          });
          int cameraPosition = isCameraFront ? 0 : 1;
          _cameraController = CameraController(
            cam[cameraPosition],
            ResolutionPreset.low,
          );
          cameravalue = _cameraController.initialize();
        });
  }
}

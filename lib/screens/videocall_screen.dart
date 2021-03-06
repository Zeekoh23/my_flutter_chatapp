import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

import 'package:provider/provider.dart';

import '../providers/agora_provider.dart';
import '../constants.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  late RtcEngine _engine;
  late String token;
  bool _joined = false;
  bool _switch = false;
  bool muted = false;
  late RtcStats _stats;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    initForAgora();
  }

  @override
  dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  Future<void> initForAgora() async {
    token =
        await Provider.of<AgoraProvider>(context, listen: false).agoraToken();
    print(token);
    await [Permission.microphone, Permission.camera].request();
    // Create RTC client instance
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine.enableVideo();

    // Define event handling logic
    _engine.setEventHandler(
      RtcEngineEventHandler(
          joinChannelSuccess: (String channel, int uid, int elapsed) {
        setState(() {
          _joined = true;
        });
        print('local user $uid joined');
      }, userJoined: (int uid, int elapsed) {
        print("remote user $uid joined");
        setState(() {
          _remoteUid = uid;
        });
      }, userMuteAudio: (int uid, bool mute) {
        setState(() {
          muted = mute;
        });
      }, leaveChannel: (RtcStats stats) {
        setState(() {
          _remoteUid = null;
        });
      }, userOffline: (int uid, UserOfflineReason reason) {
        print("remote user $uid left channel");
        setState(() {
          _remoteUid = null;
        });
      }, rtcStats: (RtcStats stats) {
        if (_showStats) {
          setState(() {
            _stats = stats;
          });
        }
      }),
    );

    //enable video
    await _engine.enableVideo();

    // Join channel with channel name
    await _engine.joinChannel(token, "ezechannel", null, 0);
  }

  @override
  Widget build(BuildContext context) {
    final viewinsets = MediaQuery.of(context).viewInsets;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _switch = !_switch;
                  });
                },
                child: Center(
                  child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              child: _showStats
                  ? Text(_stats.duration.toString())
                  : const SizedBox(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: viewinsets.bottom + size.height - 570,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        muted = !muted;
                      });
                      _engine.muteLocalAudioStream(muted);
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(
                        muted ? Icons.mic_off : Icons.mic,
                        color: kContentColorLightTheme,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  InkWell(
                    onTap: () {
                      _engine.destroy();
                      Navigator.pop(context);
                    },
                    child: const CircleAvatar(
                      child: Icon(
                        Icons.local_phone,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.red,
                      radius: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  InkWell(
                    onTap: () {
                      _engine.switchCamera();
                    },
                    child: const CircleAvatar(
                      child: Icon(
                        Icons.flip_camera_ios,
                        color: kContentColorLightTheme,
                      ),
                      backgroundColor: Colors.white,
                      radius: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return Transform.rotate(
          angle: 90 * pi / 180, child: RtcLocalView.SurfaceView());
    } else {
      return Text('Please join channel first', textAlign: TextAlign.center);
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(
          uid: _remoteUid!, channelId: 'ezechannel');
    } else {
      return Text('Please wait for ${widget.name} to join',
          textAlign: TextAlign.center);
    }
  }
}

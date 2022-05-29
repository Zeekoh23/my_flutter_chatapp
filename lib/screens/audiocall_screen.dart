import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/agora_provider.dart';
import '../constants.dart';
import '../widgets/stop_watch.dart';

class AudioCallScreen extends StatefulWidget {
  AudioCallScreen({Key? key, this.name, this.image}) : super(key: key);
  String? name;
  String? image;

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  int? _remoteUid;
  bool _joined = false;
  bool _switch = false;
  late RtcEngine _engine;
  late String token;
  bool muted = false;
  late RtcStats _stats;
  bool _showStats = false;
  bool isHours = true;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countUp,
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
    //to make sure the screen do not rotate to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    initCallState();
    _stopWatchTimer.rawTime.listen(
        (val) => print('rawTime $val ${StopWatchTimer.getDisplayTime(val)}'));
    _stopWatchTimer.records.listen((val) => print('records $val'));
    _stopWatchTimer.fetchStop.listen((val) => print('stop from stream'));
    _stopWatchTimer.fetchEnded.listen((val) => print('ended from stream'));
  }

  @override
  dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Future<void> initCallState() async {
    token =
        await Provider.of<AgoraProvider>(context, listen: false).agoraToken();
    await [Permission.microphone].request();
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine.enableAudio();

    _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess $channel $uid');

      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
      });
    }, userMuteAudio: (int uid, bool mute) {
      setState(() {
        muted = mute;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline $uid');
      setState(() {
        _remoteUid = 0;
      });
    }, leaveChannel: (RtcStats stats) {
      setState(() {
        _remoteUid = null;
      });
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    }, rtcStats: (RtcStats stats) {
      if (_showStats) {
        setState(() {
          _stats = stats;
        });
      }
    }));
    //await _engine.enableLocalAudio(true);

    await _engine.joinChannel(token, 'ezechannel', null, 0);
  }

  @override
  Widget build(BuildContext context) {
    final viewinsets = MediaQuery.of(context).viewInsets;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call'), centerTitle: true),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CircleAvatar(
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/person.png'),
                          image: NetworkImage(widget.image!),
                        ),
                        radius: kDefaultPadding * 5)),
                const SizedBox(height: 35),
                Text(
                  widget.name!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(
                  height: 8,
                ),
                _renderRemoteTimer()
              ],
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
                  const SizedBox(width: 18),
                  InkWell(
                    onTap: () {
                      _engine.destroy();
                      setState(() {
                        _remoteUid = null;
                      });

                      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderRemoteTimer() {
    if (_remoteUid != null) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      return StopWatch(stopWatchTimer: _stopWatchTimer, isHours: isHours);
    }
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    return Text('waiting for ${widget.name} to join',
        style: TextStyle(fontSize: 16));
  }
}

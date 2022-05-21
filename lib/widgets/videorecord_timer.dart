import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import './blinking_button.dart';
import './stop_watch.dart';

class VideoRecordTimer extends StatelessWidget {
  VideoRecordTimer(
      {Key? key, required this.stopWatchTimer, required this.isHours})
      : super(key: key);
  StopWatchTimer stopWatchTimer;
  bool isHours;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StopWatch(stopWatchTimer: stopWatchTimer, isHours: isHours),
          const SizedBox(width: 3),
          MyBlinkingButton(),
        ],
      ),
    );
  }
}

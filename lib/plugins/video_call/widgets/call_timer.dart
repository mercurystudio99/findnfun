import 'dart:async';

import 'package:flutter/material.dart';

class CallTimer extends StatefulWidget {
  const CallTimer({Key? key}) : super(key: key);

  @override
  _CallTimerState createState() => _CallTimerState();
}

class _CallTimerState extends State<CallTimer> {
  // Variables
  late Timer _timer;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;
  // Prefix variables
  String _secZeroPrefix = "0";
  String _minZeroPrefix = "0";
  String _hourZeroPrefix = "0";

  void _updateZeroPrefixData() {
    // Reset zero prefix data
    //
    // For seconds
    if (seconds > 9) {
      _secZeroPrefix = "";
    } else {
      _secZeroPrefix = "0";
    }
    // For minutes
    if (minutes > 9) {
      _minZeroPrefix = "";
    } else {
      _minZeroPrefix = "0";
    }
    // For hours
    if (hours > 9) {
      _hourZeroPrefix = "";
    } else {
      _hourZeroPrefix = "0";
    }
  }

  // Count the call duration
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      // Update values
      setState(
        () {
          if (seconds < 0) {
            timer.cancel();
          } else {
            // Update seconds
            seconds = seconds + 1;
            // Update zero prefix data
            _updateZeroPrefixData();

            if (seconds > 59) {
              minutes += 1;
              seconds = 0;
              if (minutes > 59) {
                hours += 1;
                minutes = 0;
              }
            }
          }
        },
      );
    });
  }

  @override
  void initState() {
    _startTimer();
    debugPrint('CallTimer -> started');
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    debugPrint('CallTimer -> cancelled');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        '$_hourZeroPrefix$hours:' // Count hours
        '$_minZeroPrefix$minutes:' // Count minutes
        '$_secZeroPrefix$seconds', // Count seconds
        style: const TextStyle(color: Colors.white, fontSize: 18));
  }
}

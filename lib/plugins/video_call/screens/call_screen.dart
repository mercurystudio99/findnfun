import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:dating_app/models/app_model.dart';
import 'package:dating_app/plugins/video_call/datas/call_info.dart';
import 'package:dating_app/plugins/video_call/widgets/video_call.dart';
import 'package:dating_app/plugins/video_call/widgets/voice_call.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CallScreen extends StatefulWidget {
  /// Variables
  final CallInfo callInfo;

  /// Creates a call page with given channel name.
  const CallScreen({Key? key, required this.callInfo}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  //
  // Agora.io App ID
  final String agoraAppID = AppModel().appInfo.agoraAppID;
  // Remote User Id
  int? _remoteUserId;
  // Bool Variables
  bool _isVideoSwitched = false;
  bool _isMuted = false;
  bool _isSpeakerEnabled = false;
  bool _isCallPickedUp = false;
  // Other variables
  String _callType = '';
  late RtcEngine _engine;

  // Update call type value
  Future<void> _updateCallType(String type, {bool isUpdate = false}) async {
    setState(() {
      _callType = type;
    });
    debugPrint('Call type -> $type');
    if (isUpdate) {
      await _engine.enableVideo();
    }
  }

  // // Play Ringtone for outgoing call
  Future<void> _playRingtone() async {
    // Check Call info
    if (widget.callInfo.isCaller) {
      await FlutterRingtonePlayer.play(
          android: AndroidSounds.alarm,
          ios: IosSounds.electronic,
          looping: true, // Android only - API >= 28
          volume: 1.0, // Android only - API >= 28
          asAlarm: true // Android only - all APIs
          );
      debugPrint('Ringtone played!');
    }
  }

  // Stop Ringtone
  Future<void> _stopRingtone() async {
    // Check Call info
    if (widget.callInfo.isCaller) {
      await FlutterRingtonePlayer.stop();
      debugPrint('Ringtone stopped!');
    }
  }

  Future<void> _initializeAgoraSettings() async {
    // Check Agora APP ID
    if (agoraAppID.isEmpty) {
      debugPrint(
          'APP_ID missing, please provide your APP_ID, Agora Engine is not starting');
      return;
    }

    // Update call type value
    _updateCallType(widget.callInfo.callType);
    // Init Agora Engine
    await _initAgoraRtcEngine();
    // Event Handlers
    _addAgoraEventHandlers();
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(agoraAppID);
    // Check Call the call type
    switch (_callType) {
      case 'video':
        // Enable video
        await _engine.enableVideo();
        break;
      case 'audio':
        // Enable audio
        await _engine.enableAudio();
        break;
    }
    await _engine.joinChannel(null, widget.callInfo.callID, null, 0);
    // Play the ringtone sound
    await _playRingtone();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        // Error callback
        debugPrint('onError: $code');
      },
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        // On Join Channel Success callback
        debugPrint('onJoinChannel: $channel, uid: $uid');
      },
      leaveChannel: (RtcStats stats) {
        // On Leave Channel callback
        debugPrint('onLeaveChannel');
      },
      userJoined: (int uid, int elapsed) {
        // On User Joined callback
        setState(() {
          _remoteUserId = uid;
          _isCallPickedUp = true;
        });
        debugPrint('userJoined: $uid');
        // Stop the ringtone sound
        _stopRingtone();
      },
      userOffline: (int uid, UserOfflineReason reason) {
        // On User Offiline callback
        setState(() {
          _remoteUserId = null;
        });
        debugPrint('userOffline: $uid');
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    _initializeAgoraSettings();
  }

  @override
  void dispose() {
    // Stop ringtone
    _stopRingtone();
    // clear users
    _remoteUserId = null;
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  // Toggle peaker phone for Audio Call
  void _onToggleSpeakerphone() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
    _engine.setEnableSpeakerphone(_isSpeakerEnabled);
  }

  // Toggle mute for both Audio/Video
  void _onToggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _engine.muteLocalAudioStream(_isMuted);
  }

  // Switch Camera - front or rear for Video Call
  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  // Toggle Video Call View
  void _onToggleVideoSwitch() {
    setState(() {
      _isVideoSwitched = !_isVideoSwitched;
    });
  }

  Future<void> _onCallEnd() async {
    // Parameter value to send back
    String popValue = '';
    // Check to send missed call value
    if (widget.callInfo.isCaller && !_isCallPickedUp) {
      popValue = 'missed_call';
    }
    Navigator.of(context).pop<String>(popValue);
  }

  @override
  Widget build(BuildContext context) {
    // Check call type
    if (_callType == 'voice') {
      // Show voice call widget
      return VoiceCall(
          remoteUserId: _remoteUserId,
          callInfo: widget.callInfo,
          isSpeakerEnabled: _isSpeakerEnabled,
          isMuted: _isMuted,
          isCallPickedUp: _isCallPickedUp,
          onToggleSpeakerphone: _onToggleSpeakerphone,
          onVideoCall: () async {
            await _updateCallType('video', isUpdate: true);
          },
          onToggleMute: _onToggleMute,
          onCallEnd: _onCallEnd);
    } else if (_callType == 'video') {
      ///
      /// Show video call widget
      ///
      return VideoCall(
          remoteUserId: _remoteUserId,
          callInfo: widget.callInfo,
          isMuted: _isMuted,
          isCallPickedUp: _isCallPickedUp,
          onToggleMute: _onToggleMute,
          onCallEnd: _onCallEnd,
          onSwitchCamera: _onSwitchCamera,
          isVideoSwitched: _isVideoSwitched,
          onToggleVideoSwitch: _onToggleVideoSwitch);
    }

    return Container();
  }
}

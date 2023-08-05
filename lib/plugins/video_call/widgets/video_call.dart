// ignore_for_file: library_prefixes

import 'package:dating_app/plugins/video_call/widgets/call_timer.dart';
import 'package:dating_app/plugins/video_call/widgets/raw_button.dart';
import 'package:flutter/material.dart';

import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/plugins/video_call/datas/call_info.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class VideoCall extends StatelessWidget {
  // Remote User Id
  final int? remoteUserId;
  // CallInfo object
  final CallInfo callInfo;
  // bool variables
  final bool isMuted;
  final bool isCallPickedUp;
  final bool isVideoSwitched;

  // Void Callbacks
  final VoidCallback onToggleMute;
  final VoidCallback onCallEnd;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleVideoSwitch;

  const VideoCall({
    Key? key,
    // Remote User Id
    this.remoteUserId,
    // CallInfo object
    required this.callInfo,
    // bool variables
    required this.isMuted,
    required this.isCallPickedUp,
    // Void Callbacks
    required this.onToggleMute,
    required this.onCallEnd,
    required this.onSwitchCamera,
    required this.isVideoSwitched,
    required this.onToggleVideoSwitch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Init i18n
    final i18n = AppLocalizations.of(context);

    // Audio call widget
    return Material(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: [
          // Render Video Call
          Center(
            child: isVideoSwitched
                ? _renderRemoteVideo(i18n)
                : _renderLocalPreview(),
          ),
          // Render Video at the top left corner
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: onToggleVideoSwitch,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).primaryColor,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: isVideoSwitched
                          ? _renderLocalPreview()
                          : _renderRemoteVideo(i18n),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Show Video Toolbar
          _videoToolbar(context),
          // Display Call Duration
          SafeArea(
            child: Align(
                alignment: Alignment.topRight,
                child: isCallPickedUp
                    ? const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CallTimer(),
                      )
                    : const SizedBox(width: 0, height: 0)),
          ),
        ],
      ),
    );
  }

  // Render Local Video
  Widget _renderLocalPreview() {
    return const RtcLocalView.SurfaceView();
  }

  // Render Remote Video
  Widget _renderRemoteVideo(AppLocalizations i18n) {
    if (remoteUserId != null) {
      return RtcRemoteView.SurfaceView(uid: remoteUserId!, channelId: callInfo.callID);
    } else {
      return Text(
        callInfo.isCaller
            ? '${i18n.translate("calling")}\n${callInfo.userProfileName}\n${i18n.translate("please_wait")}'
            : i18n.translate("please_wait_profile_name_to_join").replaceFirst("profile_name", callInfo.userProfileName),
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      );
    }
  }

  /// Video Toolbar layout
  Widget _videoToolbar(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Mute call button
          RowButton(
            icon: Icon(isMuted ? Icons.mic_off : Icons.mic,
                size: 20,
                color: isMuted ? Colors.white : Theme.of(context).primaryColor),
            padding: 12.0,
            fillColor: isMuted ? Theme.of(context).primaryColor : Colors.white,
            onPressed: onToggleMute,
          ),

          // End Call button
          RowButton(
            icon: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            padding: 15.0,
            fillColor: Colors.redAccent,
            onPressed: onCallEnd,
          ),

          // Switch Camera button
          RowButton(
            icon: Icon(
              Icons.flip_camera_ios,
              color: Theme.of(context).primaryColor,
              size: 20.0,
            ),
            padding: 12.0,
            fillColor: Colors.white,
            onPressed: onSwitchCamera,
          ),
        ],
      ),
    );
  }
}

import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/plugins/video_call/datas/call_info.dart';
import 'package:dating_app/plugins/video_call/widgets/call_timer.dart';
import 'package:dating_app/plugins/video_call/widgets/raw_button.dart';
import 'package:flutter/material.dart';

class VoiceCall extends StatelessWidget {
  // Remote User Id
  final int? remoteUserId;
  // CallInfo object
  final CallInfo callInfo;
  // bool variables
  final bool isSpeakerEnabled;
  final bool isMuted;
  final bool isCallPickedUp;
  // Void Callbacks
  final VoidCallback onToggleSpeakerphone;
  final VoidCallback onVideoCall;
  final VoidCallback onToggleMute;
  final VoidCallback onCallEnd;

  const VoiceCall({
    Key? key,
    // Remote User Id
    required this.remoteUserId,
    // CallInfo object
    required this.callInfo,
    // bool variables
    required this.isSpeakerEnabled,
    required this.isMuted,
    required this.isCallPickedUp,
    // Void Callbacks
    required this.onToggleSpeakerphone,
    required this.onVideoCall,
    required this.onToggleMute,
    required this.onCallEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Init
    final i18n = AppLocalizations.of(context);

    // Audio call widget
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Theme.of(context).primaryColor.withAlpha(95),
        child: Stack(
          children: [
            // Audio Call features
            Container(
              padding: const EdgeInsets.only(top: 80),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).primaryColor,
                    Colors.black.withOpacity(.5)
                  ])),
              child: Column(
                children: [
                  // User profile name
                  Text(callInfo.userProfileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 30,
                      )),
                  // Call status
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: isCallPickedUp && remoteUserId != null
                        ? const CallTimer()
                        : Text(
                            callInfo.isCaller
                                ? i18n.translate('calling')
                                : '${i18n.translate("please_wait_profile_name_to_join").replaceFirst("profile_name", callInfo.userProfileName)}\n\n'
                                    '${i18n.translate("if_this_takes_more_than_30_seconds_the_user_is_offline_now")}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center),
                  ),
                  // User profile image
                  CircleAvatar(
                      radius: 80,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage:
                          NetworkImage(callInfo.userProfilePhoto)),
                  const SizedBox(height: 25),
                  // Call actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enable speaker option
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RowButton(
                              icon: Icon(Icons.volume_up,
                                  size: 28,
                                  color: isSpeakerEnabled
                                      ? Theme.of(context).primaryColor
                                      : Colors.white),
                              fillColor:
                                  isSpeakerEnabled ? Colors.white : Colors.teal,
                              onPressed: onToggleSpeakerphone),
                          const SizedBox(height: 5),
                          Text(i18n.translate('speacker'),
                              style: const TextStyle(color: Colors.white))
                        ],
                      ),
                      const SizedBox(width: 25),
                      // Enable Video Call option
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RowButton(
                              icon: const Icon(Icons.videocam,
                                  size: 28, color: Colors.white),
                              fillColor: Colors.teal,
                              onPressed: onVideoCall),
                          const SizedBox(height: 5),
                          Text(i18n.translate('video_call'),
                              style: const TextStyle(color: Colors.white))
                        ],
                      ),
                      const SizedBox(width: 25),
                      // Enable Mute option
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RowButton(
                            icon: Icon(isMuted ? Icons.mic_off : Icons.mic,
                                size: 28,
                                color: isMuted
                                    ? Theme.of(context).primaryColor
                                    : Colors.white),
                            fillColor: isMuted ? Colors.white : Colors.teal,
                            onPressed: onToggleMute,
                          ),
                          const SizedBox(height: 5),
                          Text(i18n.translate('mute'),
                              style: const TextStyle(color: Colors.white))
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  /// End Call button
                  RowButton(
                    icon: const Icon(Icons.call_end, color: Colors.white, size: 35),
                    fillColor: Colors.red,
                    onPressed: onCallEnd,
                  )
                ],
              ),
            ),
            // Close button
            Positioned(
              left: 0,
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: onCallEnd),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(i18n.translate('audio_call'),
                        style: const TextStyle(fontSize: 19, color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

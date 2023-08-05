import 'package:dating_app/datas/user.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/video_call/datas/call_info.dart';
import 'package:dating_app/plugins/video_call/utils/call_helper.dart';
import 'package:dating_app/plugins/video_call/widgets/raw_button.dart';
import 'package:dating_app/screens/chat_screen.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class IncomingCall extends StatefulWidget {
  // CallInfo object
  final CallInfo callInfo;

  const IncomingCall({
    Key? key,
    // CallInfo object
    required this.callInfo,
  }) : super(key: key);

  @override
  _IncomingCallState createState() => _IncomingCallState();
}

class _IncomingCallState extends State<IncomingCall> {
  // Play Incoming Call Ringtone
  Future<void> _playRingtone() async {
    await FlutterRingtonePlayer.playRingtone();
    debugPrint('Ringtone played!');
  }

  // Stop Ringtone
  Future<void> _stopRingtone() async {
    await FlutterRingtonePlayer.stop();
    debugPrint('Ringtone stopped!');
  }

  @override
  void initState() {
    super.initState();
    _playRingtone();
  }

  @override
  void dispose() {
    _stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Init
    final i18n = AppLocalizations.of(context);

    // Incoming Call widget
    return Material(
        color: Colors.black.withOpacity(.55),
        child: Center(
          child: SingleChildScrollView(
              child: Stack(
            children: [
              // Incoming Call features
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [
                      Theme.of(context).primaryColor,
                      Colors.black.withOpacity(.5)
                    ])),
                child: Column(children: [
                  // User profile name
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(widget.callInfo.userProfileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 30,
                        )),
                  ),
                  // Call status
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(widget.callInfo.callTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        )),
                  ),
                  // User profile image
                  CircleAvatar(
                      radius: 80,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage:
                          NetworkImage(widget.callInfo.userProfilePhoto)),
                  const SizedBox(height: 25),

                  // Send message button
                  GestureDetector(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // icon
                        const SvgIcon("assets/icons/message_2_icon.svg",
                            width: 40, height: 40, color: Colors.white),
                        Text(i18n.translate('message'),
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    onTap: () async {
                      // Get User info
                      final User user = await UserModel()
                          .getUserObject(widget.callInfo.userId);
                      debugPrint(user.toString());
                      // Go to chat screen
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => ChatScreen(user: user)))
                          .then((_) {
                        // Close this dialog
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                  const SizedBox(height: 25),

                  // Call actions
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // Decline Call option
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RowButton(
                            icon: const Icon(Icons.close,
                                size: 35, color: Colors.white),
                            fillColor: Colors.red,
                            onPressed: () => Navigator.of(context).pop()),
                        const SizedBox(height: 5),
                        Text(i18n.translate('decline'),
                            style: const TextStyle(color: Colors.white))
                      ],
                    ),

                    const SizedBox(width: 30),

                    // Accept Call option
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RowButton(
                            icon: const Icon(Icons.check,
                                size: 35, color: Colors.white),
                            fillColor: Colors.blue,
                            onPressed: () async {
                              // Accept and Go to Call screen
                              CallHelper.onJoinCall(context,
                                  callInfo: widget.callInfo);
                              // Close this dialog
                              Navigator.of(context).pop();
                            }),
                        const SizedBox(height: 5),
                        Text(i18n.translate('accept'),
                            style: const TextStyle(color: Colors.white))
                      ],
                    ),
                  ]),
                  const SizedBox(height: 40),
                ]),
              )
            ],
          )),
        ));
  }
}

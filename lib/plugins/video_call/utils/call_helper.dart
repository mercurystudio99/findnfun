import 'dart:io';

import 'package:dating_app/api/messages_api.dart';
import 'package:dating_app/api/notifications_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/main.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/video_call/datas/call_info.dart';
import 'package:dating_app/plugins/video_call/screens/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// final instances
final _notificationsApi = NotificationsApi();
final _messagesApi = MessagesApi();

class CallHelper {
  // Join to Call method
  static Future<void> onJoinCall(BuildContext context,
      {required CallInfo callInfo, User? userReceiver}) async {
    // await for camera and mic permissions before pushing to call page
    // Check Platform
    if (Platform.isAndroid) {
      final pStatus = await [
        Permission.camera,
        Permission.microphone,
        Permission.storage
      ].request();
      debugPrint(pStatus.toString());
    }
    // Go to video call page and return the result
    final String? result = await Future<String?>(() {
      return navigatorKey.currentState!.push<String?>(
        MaterialPageRoute(
          builder: (context) => CallScreen(
            callInfo: callInfo,
          ),
        ),
      );
    });

    // Debug
    debugPrint('onJoinCall() -> result: $result');

    // Check the result to take action
    if (result == 'missed_call') {
      // Check to send missed call to receiver
      await _missedCallNotification(context,
          userReceiver: userReceiver!, callType: callInfo.callType);
    }
  }

  // Make Audio or Video Call
  static Future<void> makeCall(BuildContext context,
      {required User userReceiver, required String callType}) async {
    // Local variables
    final i18n = AppLocalizations.of(context);
    // Get correct title
    final String callTitle = callType == 'video'
        ? i18n.translate('incoming_video_call')
        : i18n.translate('incoming_voice_call');

    // 01 Create Call Info object with Current User Data to show Receiver User.
    final CallInfo callerInfo = CallInfo(
        callID: UserModel().user.userId,
        userId: UserModel().user.userId,
        isCaller:
            false, // Set it: [false], since this info is sent for receiver
        callType: callType,
        callTitle: callTitle,
        userProfileName: UserModel().user.userFullname.split(' ')[0],
        userProfilePhoto: UserModel().user.userProfilePhoto);

    // Send Call Notification to Receiver
    await _notificationsApi.sendPushNotification(
        nType: 'call',
        nCallInfo: callInfoToMap(callerInfo),
        nTitle: UserModel().user.userFullname.split(' ')[0], // Caller Name
        nBody: callTitle,
        nSenderId: '',
        nUserDeviceToken: userReceiver.userDeviceToken);

    // 02 Create Call Info object with Receiver User Data to be
    // used in VoiceCall widget.
    final CallInfo receiverInfo = CallInfo(
        callID: UserModel()
            .user
            .userId, // Call ID is the Current User ID to be joined by Receiver
        userId: userReceiver.userId,
        isCaller: true, // Set it: [true], since this info is used by caller
        callType: callType,
        callTitle: callTitle,
        userProfileName: userReceiver.userFullname.split(' ')[0],
        userProfilePhoto: userReceiver.userProfilePhoto);

    // Go to video call screen
    await onJoinCall(context,
        callInfo: receiverInfo, userReceiver: userReceiver);
  }

  // Send missed call message and notification to receiver
  static Future<void> _missedCallNotification(BuildContext context,
      {required User userReceiver, required String callType}) async {
    // Local variables
    final i18n = AppLocalizations.of(context);
    // Get correct message
    final String message = callType == 'video'
        ? i18n.translate('you_missed_a_video_call')
        : i18n.translate('you_missed_a_voice_call');

    // Send message to receiver
    await _messagesApi.saveMessage(
        type: 'text',
        fromUserId: UserModel().user.userId,
        senderId: userReceiver.userId,
        receiverId: UserModel().user.userId,
        userPhotoLink: UserModel().user.userProfilePhoto, // current user photo
        userFullName: UserModel().user.userFullname, // current user ful name
        textMsg: message,
        imgLink: '',
        isRead: false);

    /// Send push notification to Receiver
    await _notificationsApi.sendPushNotification(
        nTitle: APP_NAME,
        nBody:
            '$message ${i18n.translate('from')} ${UserModel().user.userFullname.split(' ')[0]}',
        nType: 'message',
        nSenderId: UserModel().user.userId,
        nUserDeviceToken: userReceiver.userDeviceToken);
  }
}

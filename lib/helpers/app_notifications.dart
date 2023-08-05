import 'dart:convert';

import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/video_call/datas/call_info.dart';
import 'package:dating_app/plugins/video_call/widgets/incoming_call.dart';
import 'package:dating_app/screens/profile_likes_screen.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/screens/profile_visits_screen.dart';
import 'package:flutter/material.dart';

class AppNotifications {
  /// Handle notification click for push
  /// and database notifications
  Future<void> onNotificationClick(
    BuildContext context, {
    required String nType,
    required String nSenderId,
    required String nMessage,
    // Call Info object
    String? nCallInfo,
  }) async {
    // Try to Restore the VIP subscription if available to User.
    await AppHelper().restoreVipAccount();

    /// Control notification type
    switch (nType) {
      case 'like':

        /// Check user VIP account
        if (UserModel().userIsVip) {
          /// Go direct to user profile
          _goToProfileScreen(context, nSenderId);
        } else {
          /// Go Profile Likes Screen
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileLikesScreen()));
        }
        break;
      case 'visit':

        /// Check user VIP account
        if (UserModel().userIsVip) {
          /// Go direct to user profile
          _goToProfileScreen(context, nSenderId);
        } else {
          /// Go Profile Visits Screen
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileVisitsScreen()));
        }
        break;

      case 'alert':

        /// Show dialog info
        Future(() {
          infoDialog(context, message: nMessage);
        });

        break;
      

      case 'call':
      
        // Get Call Data from notification payload string
        final Map<String, dynamic> _callInfoMap = json.decode(nCallInfo!);
        // Convert to Call info object
        final CallInfo callInfo = CallInfo.fromMap(_callInfoMap);

        // Show IncomingCall dialog
        Future(() {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return IncomingCall(
                  callInfo: callInfo,
                );
              });
        });
        break;

    }
  }

  /// Navigate to profile screen
  void _goToProfileScreen(BuildContext context, userSenderId) async {
    /// Get updated user info
    final User user = await UserModel().getUserObject(userSenderId);

    /// Go direct to profile
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
  }
}

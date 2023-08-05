import 'package:dating_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:timeago/timeago.dart' as timeago;

class LastSeen extends StatelessWidget {

  // Constructor
  const LastSeen({Key? key, required this.userLastActive}) : super(key: key); 

   // Variables
  final DateTime userLastActive;

  @override
  Widget build(BuildContext context) {
    // Local Variables
    final i18n = AppLocalizations.of(context);

    // Get last seen - time ago 
    final String timeAgo = timeago.format(
      userLastActive, locale: i18n.translate('lang'));

    return SizedBox(
      height: 20,
      child: Marquee(
        blankSpace: 20.0,
        velocity: 30.0,
        style: TextStyle(color: Colors.grey[800], fontSize: 16),
        text: "${i18n.translate('last_seen')} - $timeAgo",
      ),
    );
  }
}

import 'package:dating_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PlaceHolder extends StatelessWidget {
  // Variables
  final Widget icon;

  const PlaceHolder(this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        child: Center(
          child: icon,
        ),
        baseColor: Colors.grey.withAlpha(70),
        highlightColor: APP_ACCENT_COLOR);
  }
}

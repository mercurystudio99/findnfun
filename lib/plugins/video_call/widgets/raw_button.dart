import 'package:flutter/material.dart';

class RowButton extends StatelessWidget {
  // Variables
  final Icon icon;
  final Color fillColor;
  final double? padding;
  final VoidCallback onPressed;

  // Constructor
  const RowButton({Key? key, 
    required this.icon,
    required this.fillColor,
    this.padding,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: icon,
      onPressed: onPressed,
      shape: const CircleBorder(),
      elevation: 2.0,
      fillColor: fillColor,
      padding: EdgeInsets.all(padding ?? 15.0),
    );
  }
}

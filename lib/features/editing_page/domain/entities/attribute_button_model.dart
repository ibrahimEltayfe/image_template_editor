import 'package:flutter/material.dart';

class AttributeButtonModel{
  final String title;
  final IconData icon;
  final TextStyle textStyle;
  final ButtonStyle buttonStyle;
  final Color iconColor;
  final AttributeButtonType type;

  AttributeButtonModel({
    required this.type,
    required this.icon,
    required this.title,
    required this.textStyle,
    required this.buttonStyle,
    required this.iconColor,
  });
}

enum AttributeButtonType{
  textSize,
  fontFamily,
  fontWeight,
  textColor,

  resize,
  crop,
  blackAndWhite,
  removeBg
}

import 'package:flutter/material.dart';

class MainButtonModel{
  final String title;
  final MainButtonsType type;
  final ButtonStyle buttonStyle;
  final TextStyle textStyle;

  const MainButtonModel({
    required this.textStyle,
    required this.buttonStyle,
    required this.title,
    required this.type
  });
}
enum MainButtonsType{
  image,text
}

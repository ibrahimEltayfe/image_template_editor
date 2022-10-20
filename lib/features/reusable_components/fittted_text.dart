import 'package:flutter/material.dart';

class FittedText extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final TextStyle textStyle;
  const FittedText({Key? key, required this.height, required this.width, required this.text, required this.textStyle, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: FittedBox(
                child: Text(text,style: textStyle)
            ),
          )
      ),
    );
  }
}

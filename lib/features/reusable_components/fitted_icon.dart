import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FittedFaIcon extends StatelessWidget {
  final double height;
  final double width;
  final IconData icon;
  final Color color;
  const FittedFaIcon({Key? key, required this.height, required this.width, required this.icon, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: FittedBox(
              child: FaIcon(icon,color: color)
          ),
        )
    );
  }
}

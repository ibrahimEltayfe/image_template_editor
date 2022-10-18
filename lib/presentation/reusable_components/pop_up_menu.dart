import 'package:flutter/material.dart';
import 'package:image_manipulate/core/extensions/get_element_bounds.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

Future<void> popUpMenu(BuildContext context,void Function(int) onTap) async{

  final offset = context.globalPaintBounds;

  final left = offset?.left ?? 300;
  final top = offset?.top ?? 300;
  final right =offset?.right ?? 150;
  final bottom = offset?.bottom ?? 300;

  await showMenu(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight:  Radius.circular(20)
        )
    ),
    position: RelativeRect.fromLTRB(left, top, right,bottom),
    items: List.generate(ImageDropMenu.values.length, (i) {
      return PopupMenuItem<String>(
        textStyle: getBoldTextStyle(color:ImageDropMenu.values[i]== ImageDropMenu.delete?AppColors.red:AppColors.black),
        onTap: (){
          onTap(i);
        },
       child: Text(ImageDropMenu.values[i].getText()),
      );
    }),
    elevation: 8.0,
  );
}

enum ImageDropMenu{
  delete,
  change,
}

extension menuActions on ImageDropMenu{
  String getText(){
    switch(this) {
      case ImageDropMenu.delete: return "delete";
      case ImageDropMenu.change: return "change";
    }
  }
}

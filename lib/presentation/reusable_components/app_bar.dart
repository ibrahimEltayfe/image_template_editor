import 'package:flutter/material.dart';
import 'package:image_manipulate/core/constants/app_styles.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import 'package:image_manipulate/presentation/editing_page/view_model/editing_view_model.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import 'fitted_icon.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final EditingViewModel editingViewModel;
  const CustomAppBar({Key? key, required this.editingViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,

      leading: _BuildMenuButton(editingViewModel),
      actions: [
        _BuildUndoButtons(
          leftUndoTapAction:() {},
          rightUndoTapAction:() {} ,
        ),

        SizedBox(width: context.width*0.04,),

        _BuildSaveButton(
          saveTapAction: () {},
        ),

        SizedBox(width: context.width*0.04,),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BuildUndoButtons extends StatelessWidget {
  final VoidCallback leftUndoTapAction;
  final VoidCallback rightUndoTapAction;
  const _BuildUndoButtons({Key? key, required this.leftUndoTapAction, required this.rightUndoTapAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: context.width*0.28,
        height: kToolbarHeight*0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: AppColors.mediumGrey
        ),
        child: LayoutBuilder(
          builder: (p0, p1) =>
              Row(
                children: [
                  SizedBox(width: p1.maxWidth*0.1,),

                  Expanded(
                    child: GestureDetector(
                      onTap: leftUndoTapAction,
                      child: FittedFaIcon(
                        width: p1.maxWidth*0.3,
                        height: p1.maxHeight*0.6,
                        color: AppColors.black87,
                        icon: AppIcons.leftUndo,
                      ),
                    ),
                  ),

                  Expanded(
                      child: VerticalDivider(
                        color: AppColors.grey,
                        indent: p1.maxHeight*0.2,
                        endIndent: p1.maxHeight*0.2,
                        thickness: p1.maxWidth*0.005,
                      )
                  ),

                  Expanded(
                    child:GestureDetector(
                      onTap: rightUndoTapAction,
                      child: FittedFaIcon(
                        width: p1.maxWidth*0.3,
                        height: p1.maxHeight*0.6,
                        color: AppColors.black87,
                        icon: AppIcons.rightUndo,
                      ),
                    ),
                  ),

                  SizedBox(width: p1.maxWidth*0.1,),
                ],
              ),
        ),
      ),
    );
  }
}

class _BuildSaveButton extends StatelessWidget {
  final VoidCallback saveTapAction;
  const _BuildSaveButton({Key? key, required this.saveTapAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: saveTapAction,
        child: Container(
          alignment: Alignment.center,
          width: context.width*0.12,
          height: kToolbarHeight*0.7,
          decoration:BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: AppColors.mediumGrey
          ),
          child: LayoutBuilder(
            builder: (p0, p1) =>
                FittedFaIcon(
                    width: p1.maxWidth*0.8,
                    height: p1.maxHeight*0.8,
                    icon: AppIcons.save,
                    color: AppColors.black87
                ),
          ),
        ),
      ),
    );
  }
}

class _BuildMenuButton extends StatelessWidget {
  final EditingViewModel editingViewModel;
  _BuildMenuButton(this.editingViewModel,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showMenu(
          context: context,
          position: const RelativeRect.fromLTRB(40, 40, 40, 40),
          items: List.generate(
              MenuActions.values.length, (i) {
               return PopupMenuItem<String>(
                 textStyle: getBoldTextStyle(color: MenuActions.values[i] == MenuActions.close ? AppColors.red : AppColors.black),
                 onTap: (){

                 },
                 child: Text(MenuActions.values[i].getText()),
               );
           }),
          elevation: 8.0,
        );
      },
      child: const Icon(AppIcons.menu,color: AppColors.black87,size:  kToolbarHeight * 0.5,),
    );
  }
}

enum MenuActions{
  newProject,
  openProject,
  close
}

extension menuActions on MenuActions{
  String getText(){
    switch(this) {
      case MenuActions.newProject: return "New Project";
      case MenuActions.openProject: return "Open Project";
      case MenuActions.close: return "Close Project";
    }
  }

}


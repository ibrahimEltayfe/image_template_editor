import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_manipulate/core/constants/app_icons.dart';
import 'package:image_manipulate/core/constants/app_strings.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import '../../../../../core/constants/app_colors.dart';
import '../view_model/editing_view_model.dart';

class BuildEditingButtons extends StatelessWidget {
  final EditingViewModel editingViewModel;
  final double height;
  const BuildEditingButtons({Key? key, required this.editingViewModel, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Container(
        width: context.width,
        height: height,
        color: AppColors.bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(height: 0.0015*height,color: AppColors.mediumGrey),
            SizedBox(height: 0.01 * height,),

            Expanded(child: _GetAttributesButtons(editingViewModel: editingViewModel,),),

          ],
        ),
      );

  }
}
class _GetAttributesButtons extends StatelessWidget {
  final EditingViewModel editingViewModel;
  const _GetAttributesButtons({Key? key, required this.editingViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints1) => StreamBuilder(
          stream:editingViewModel.attributeButtonsOutput,
          builder:(context, subButtonsList) {
            final subButtons = editingViewModel.attributeButtons;

            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subButtons.length,
                itemBuilder:(context, i){
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: constraints1.maxHeight*0.075),
                    child: SizedBox(
                      width: constraints1.maxWidth*0.22,
                      child: Column(
                        children: [
                          SizedBox(
                            height: constraints1.maxHeight*0.53,
                            child: ElevatedButton(
                                style: subButtons[i].buttonStyle,
                                onPressed:  (){
                                  editingViewModel.changeAttributeButtons(subButtons[i].type);
                                },
                                child: FractionallySizedBox(
                                    heightFactor:0.52,
                                    widthFactor: 0.52,
                                    child: FittedBox(
                                      child: Icon(
                                          subButtons[i].icon,
                                          color: subButtons[i].iconColor
                                      ),
                                    ),
                                  )
                            ),
                          ),

                          SizedBox(height: context.height*0.009,),

                          Expanded(
                            child: FittedBox(
                              child: Text(
                                  subButtons[i].title,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style:subButtons[i].textStyle
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
          }
      ),
    );
  }
}







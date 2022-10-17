import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_manipulate/core/constants/app_icons.dart';
import 'package:image_manipulate/core/constants/app_strings.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import 'package:image_manipulate/presentation/editing_page/view_model/editing_view_model.dart';
import 'package:image_manipulate/presentation/reusable_components/fitted_icon.dart';
import 'package:image_manipulate/presentation/reusable_components/fittted_text.dart';
import '../../../core/constants/app_colors.dart';

class BuildEditingModeButtons extends StatelessWidget {
  final EditingViewModel editingViewModel;
  final double height;
  const BuildEditingModeButtons({Key? key, required this.editingViewModel, required this.height}) : super(key: key);

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
      builder: (_, p1) => StreamBuilder(
          stream:editingViewModel.attributeButtonsOutput,
          builder:(context, subButtonsList) {
            final subButtons = subButtonsList.data;
            if (subButtons == null) {
              return const SizedBox.shrink();
            }

            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subButtons.length,
                itemBuilder:(context, i){
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: p1.maxHeight*0.075),
                    child: SizedBox(
                      width: p1.maxWidth*0.22,
                      child: Column(
                        children: [
                          SizedBox(
                            height: p1.maxHeight*0.53,
                            child: ElevatedButton(
                                style: subButtons[i].buttonStyle,
                                onPressed:  (){
                                  //todo add ontap
                                  editingViewModel.changeAttributeButtons(subButtons[i].type);
                                },
                                child:LayoutBuilder(
                                    builder: (_,constraints) {
                                      return SizedBox(
                                        height: constraints.maxHeight*0.52,
                                        width: constraints.maxWidth*0.52,
                                        child: FittedBox(
                                          child: Icon(
                                              subButtons[i].icon,
                                              color: subButtons[i].iconColor
                                          ),
                                        ),
                                      );
                                    }
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







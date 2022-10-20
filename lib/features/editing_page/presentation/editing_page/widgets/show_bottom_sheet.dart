import 'package:flutter/material.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import 'package:image_manipulate/features/editing_page/domain/entities/attribute_button_model.dart';
import 'package:image_manipulate/features/editing_page/presentation/editing_page/view_model/editing_view_model.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_styles.dart';
import '../../../../reusable_components/fittted_text.dart';
import 'custom_slider.dart';

class ShowBottomSheet extends StatefulWidget {
  final EditingViewModel editingViewModel;
  const ShowBottomSheet({Key? key, required this.editingViewModel}) : super(key: key);

  @override
  State<ShowBottomSheet> createState() => _ShowBottomSheetState();
}

class _ShowBottomSheetState extends State<ShowBottomSheet> with SingleTickerProviderStateMixin{
  late final AnimationController animationController;
  late final CurvedAnimation curvedAnimation;
  @override
  void initState() {
   animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
   curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.ease);

   super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.editingViewModel.showBottomSheetOutput,
      builder: (context, snapshot) {
        if(snapshot.data == true){
          animationController.forward();
        }else if(snapshot.data == false){
          animationController.reverse();
        }
        //show the done-cancel-feather bottom sheet
        return AnimatedBuilder(
            animation: curvedAnimation,
            builder: (context, child) {
              if(animationController.value == 0){
                return SizedBox.shrink();
              }
              return Transform.translate(
                  offset:Offset(0,(1-curvedAnimation.value)*context.height * 0.3),
                  child: child,
              );
            },
            child: Container(
              height:context.height * 0.27,
              decoration:const BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20) ,
                  topLeft: Radius.circular(20)
                ),
                boxShadow: [
                  BoxShadow(offset: Offset(0,-3),color: AppColors.mediumGrey,blurRadius: 6)
                ]
              ),

              child: ApplyChangesBottomSheet(editingViewModel: widget.editingViewModel,),
            )
        );

      },
    );
  }
}

class ApplyChangesBottomSheet extends StatelessWidget {
  final EditingViewModel editingViewModel;
  const ApplyChangesBottomSheet({Key? key, required this.editingViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, p1) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: p1.maxWidth*0.03,vertical: p1.maxHeight*0.13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomSlider(
                  width: p1.maxWidth*0.92,
                  height: p1.maxHeight*0.2,
                  label:'Feather',
                  editingViewModel: editingViewModel
              ),

              SizedBox(height: p1.maxHeight*0.22,),

              SizedBox(
                height: p1.maxHeight*0.24,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _BuildActionButton(
                        onTap: (){
                          //close
                          editingViewModel.changeBottomSheetState(false);
                          //todo:(get the old image back)

                        },
                        height: p1.maxHeight*0.4,
                        bgColor: AppColors.mediumGrey,
                        child: FittedText(
                          width: p1.maxWidth*0.7,
                          height: p1.maxHeight*0.7,
                          text: AppStrings.cancel,
                          textStyle: getBoldTextStyle(color: AppColors.black87),
                          //color: AppColors.black87,
                          // icon: AppIcons.close,
                        ),
                      ),
                    ),

                    SizedBox(width: p1.maxWidth*0.03,),

                    Expanded(
                      flex: 1,
                      child: _BuildActionButton(
                        onTap: () async{
                          //done
                          await editingViewModel.saveImage();
                          editingViewModel.changeBottomSheetState(false);

                        },
                        height: p1.maxHeight*0.4,
                        bgColor: AppColors.primaryColor,
                        child: FittedText(
                          width: p1.maxWidth*0.7,
                          height: p1.maxHeight*0.7,
                          text: AppStrings.done,
                          textStyle: getBoldTextStyle(color: AppColors.white),
                          //color: AppColors.white,
                          //icon: AppIcons.done,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BuildActionButton extends StatelessWidget {
  final double height;
  final Color bgColor;
  final Widget child;
  final VoidCallback onTap;

  const _BuildActionButton({
    Key? key,
    required this.height,
    required this.bgColor,
    required this.child,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: bgColor,
        ),
        child: child,
      ),
    );
  }
}



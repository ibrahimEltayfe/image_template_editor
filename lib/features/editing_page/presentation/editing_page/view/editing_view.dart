import 'dart:developer';
import 'dart:io';
import 'package:cyclop/cyclop.dart';
import 'package:flutter/material.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import 'package:image_manipulate/core/utils/injector.dart' as di;
import 'package:image_manipulate/features/editing_page/presentation/editing_page/widgets/remove_bg.dart';
import 'package:image_manipulate/features/editing_page/presentation/editing_page/widgets/resizable_widget.dart';
import 'package:image_manipulate/features/editing_page/presentation/editing_page/view_model/editing_view_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../reusable_components/app_bar.dart';
import '../../../../reusable_components/pop_up_menu.dart';
import '../../../domain/entities/attribute_button_model.dart';
import '../../../domain/entities/image_model.dart';
import '../widgets/bottom_image_controller.dart';
import '../widgets/build_editing_mode.dart';
import '../widgets/show_bottom_sheet.dart';

class EditingPage extends StatefulWidget {
  final XFile image;
  const EditingPage({Key? key, required this.image}) : super(key: key);

  @override
  State<EditingPage> createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  final EditingViewModel editingViewModel = EditingViewModel(di.injector());

  @override
  void initState() {
    editingViewModel.start(widget.image);
    super.initState();
  }

  @override
  void dispose() {
    editingViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actualScreenHeight = context.height - context.topPadding - kToolbarHeight - context.bottomPadding;

    return EyeDrop(
      child: Scaffold(
        appBar: CustomAppBar(editingViewModel: editingViewModel,),

        body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: actualScreenHeight,
                width: context.width,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _EditingSpace(
                          height: actualScreenHeight * 0.69,
                          editingViewModel: editingViewModel,
                        ),

                        BuildEditingButtons(
                          height:actualScreenHeight * 0.106,
                          editingViewModel:editingViewModel
                        ),

                        Expanded(
                          child: BottomControlBar(
                              height: actualScreenHeight * 0.2,
                              editingViewModel: editingViewModel
                          ),
                        )
                      ],
                    ),

                    Positioned(
                        bottom: 0,
                        height:context.height * 0.27,
                        width: context.width,
                        child:ShowBottomSheet(editingViewModel:editingViewModel)
                    )

                  ]
                ),
              ),
            )

        ),
      ),
    );
  }
}


class _EditingSpace extends StatelessWidget {
  final double height;
  final EditingViewModel editingViewModel;
  _EditingSpace({Key? key, required this.editingViewModel, required this.height}) : super(key: key);

  final containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
            width: context.width,
            height: height,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.mediumGrey,width: context.width*0.03)
            ),

            child: StreamBuilder(
                stream:editingViewModel.attributeButtonsOutput,
                builder: (context, attributeButton) {
                    return StreamBuilder(
                      stream: editingViewModel.selectedImageOutput,
                      builder: (context, selectedIndex) {
                        final List<ImageModel> list = editingViewModel.imageList;

                        List<Widget> imageList = List.generate(list.length, (index){
                          if(list[index].width == 0 && list[index].height==0){
                            editingViewModel.imageList[index].width = context.width * 0.95;
                            editingViewModel.imageList[index].height = height * 0.97;
                          }

                          return _AttributeButtonsCases(
                            editingViewModel: editingViewModel,
                            index: index,
                          );

                      }
                    );

                        return Stack(
                          children: imageList,
                        );
                  });
                })
        ),

        //eye drop
        //todo:make it draggable
          Positioned(
            bottom: height*0.04,
            height: height*0.25,
            width: context.width * 0.4,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: StreamBuilder(
                stream: editingViewModel.attributeButtonsOutput,
                builder:(context, subButtons) {
                  if(subButtons.data == null){
                    return const SizedBox.shrink();
                  }
                  if(editingViewModel.attributeButtonType == AttributeButtonType.removeBg){
                    return ColorEyeDrop(height: height,editingViewModel: editingViewModel,);
                  }else{
                    //todo:
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}


class _AttributeButtonsCases extends StatelessWidget {
  final EditingViewModel editingViewModel;
  final int index;
  const _AttributeButtonsCases({Key? key, required this.editingViewModel, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(editingViewModel.selectedImageIndex != index){
      return _BuildImage(editingViewModel: editingViewModel, index: index);
    }else{
      switch(editingViewModel.attributeButtonType){
        case AttributeButtonType.resize:
          return ResizableWidget(
              editingViewModel: editingViewModel,
              index: index,
              ballDiameter: context.width *0.05,
          );

        case AttributeButtonType.removeBg:
            return RemoveBackground(
              imageModel: editingViewModel.imageList[index],
              index: index,
              editingViewModel: editingViewModel,
            );

        default: return ResizableWidget(
            editingViewModel: editingViewModel,
            index: index,
            ballDiameter: context.width *0.05,
        );
      }
    }
  }
}

class _BuildImage extends StatelessWidget {
  final EditingViewModel editingViewModel;
  final int index;
  const _BuildImage({Key? key, required this.editingViewModel, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageModel imageModel = editingViewModel.imageList[index];
    return  Builder(
        builder: (context) {
          return GestureDetector(
              onLongPress: () async{
                editingViewModel.changeSelectedImageIndex(index);

                await popUpMenu(context, (i){
                  if(ImageDropMenu.values[i]==ImageDropMenu.delete){
                    editingViewModel.deleteImage();
                  }else if(ImageDropMenu.values[i] == ImageDropMenu.change){
                    editingViewModel.pickGalleryImage(isChangeImage: true);
                  }

                },);
              },
              child:Stack(
                children: [
                  Positioned(
                      top: imageModel.top,
                      left: imageModel.left,
                      child: GestureDetector(
                        onTap:(){
                          editingViewModel.changeSelectedImageIndex(index);
                        },

                        child: SizedBox(
                            width: imageModel.width,
                            height:imageModel.height,
                            child: FittedBox(
                                fit: BoxFit.fill,
                                child: Image.file(File(imageModel.imageFile.path),fit: BoxFit.fill)
                            )
                        ),
                      )
                  )
                ],
              )
          );
        }
    );
  }
}

class ColorEyeDrop extends StatefulWidget {
  final double height;
  final EditingViewModel editingViewModel;
  const ColorEyeDrop({Key? key, required this.height, required this.editingViewModel}) : super(key: key);

  @override
  State<ColorEyeDrop> createState() => _ColorEyeDropState();
}

class _ColorEyeDropState extends State<ColorEyeDrop> {
  Color color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height*0.16,
        width: context.width * 0.30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.lightGrey.withOpacity(0.8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.width*0.02,vertical: widget.height*0.02),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: color
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: EyedropperButton(
                key: Key('c1'),
                onColor: (value) {
                  widget.editingViewModel.changeBGRemoverValues(
                    red: value.red,
                    green: value.green,
                    blue: value.blue,
                  );
                },
                onColorChanged: (value) {
                  setState((){color = value;});
                },
              ),
            ),

            SizedBox(width: context.width*0.015,)

          ],
        )
    );

  }
}



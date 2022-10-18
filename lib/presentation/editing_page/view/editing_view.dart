import 'dart:developer';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/constants/app_styles.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import 'package:image_manipulate/core/utils/injector.dart' as di;
import 'package:image_manipulate/presentation/editing_page/widgets/resizable_widget.dart';
import 'package:image_manipulate/presentation/editing_page/view_model/editing_view_model.dart';
import 'package:image_manipulate/presentation/reusable_components/app_bar.dart';
import 'package:image_manipulate/presentation/reusable_components/pop_up_menu.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/bottom_toolbar.dart';
import '../widgets/build_editing_mode.dart';

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

    return Scaffold(
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

                      BuildEditingModeButtons(
                        height:actualScreenHeight * 0.105,
                        editingViewModel:editingViewModel
                      ),

                      Expanded(
                        child: BottomToolBar(
                            height: actualScreenHeight * 0.2,
                            editingViewModel: editingViewModel
                        ),
                      )
                    ],
                  ),

                ]
              ),
            ),
          )

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
    return Container(
        width: context.width,
        height: height,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.mediumGrey,width: context.width*0.03)
        ),

        child: StreamBuilder(
            stream:editingViewModel.selectedImageOutput ,
            builder: (context, selectedIndex) {
              final List<ImageModel> list = editingViewModel.imageList;

              List<Widget> imageList = List.generate(list.length, (index){
                if(list[index].width == 0 && list[index].height==0){
                  editingViewModel.imageList[index].width = context.width * 0.95;
                  editingViewModel.imageList[index].height = height * 0.97;
                }
                //todo:show the menu on correct location,refactor

                return ResizableWidget(
                    isResizable:index == editingViewModel.selectedImageIndex,
                    editingViewModel: editingViewModel,
                    index: index,
                    ballDiameter: context.width *0.05,
                    child: Builder(
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
                          child: Image.file(File(list[index].imageFile.path),fit: BoxFit.fill,)
                        );
                      }
                    )
                  );
              });

              return Stack(
                children: imageList,
              );
            })
    );
  }
}

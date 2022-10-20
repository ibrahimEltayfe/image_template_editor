import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/constants/app_styles.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';

import '../../../domain/entities/image_model.dart';
import '../view_model/editing_view_model.dart';

class BottomControlBar extends StatelessWidget {
  final EditingViewModel editingViewModel;
  final double height;
  const BottomControlBar({Key? key, required this.editingViewModel, required this.height,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Divider(height: height*0.0015,color: AppColors.mediumGrey,),

          _ItemsControlSection(
              height: height*0.65,
              editingViewModel: editingViewModel
          ),

          Divider(height: height*0.0015,color: AppColors.mediumGrey),
          SizedBox(height: height*0.035,),

          _MainButtons(
            height:context.height*0.049,
            editingViewModel: editingViewModel,
          ),

          SizedBox(height: height*0.035,)

        ],
      ),
    );
  }
}

class _MainButtons extends StatelessWidget {
  final EditingViewModel editingViewModel;
  final double height;
  const _MainButtons({Key? key, required this.editingViewModel, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: editingViewModel.mainButtonsOutput,
        builder: (context,mainButtonsList) {
          final mainButtons = mainButtonsList.data;

          if(mainButtons == null){
            return const SizedBox.shrink();
          }

          return SizedBox(
            width: context.width,
            height: height,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mainButtons.length,
                itemBuilder:(context, i) {
                  return Padding(
                    padding: EdgeInsets.only(left: context.width*0.02),
                    child: SizedBox(
                      width: context.width*0.3,
                      child: ElevatedButton(
                          style:mainButtons[i].buttonStyle,

                          onPressed: (){
                            editingViewModel.changeMainButtons(mainButtons[i].type);
                            //todo add ontap

                          },
                          child: FractionallySizedBox(
                            widthFactor: 0.6,
                            heightFactor: 0.6,
                            child: FittedBox(
                              child: Text(
                                mainButtons[i].title,
                                style:mainButtons[i].textStyle,
                                maxLines: 1,
                              ),
                            ),
                          )

                      ),
                    ),
                  );}
            ),
          );
        });
  }
}

class _ItemsControlSection extends StatefulWidget {
  final double height;
  final EditingViewModel editingViewModel;
  const _ItemsControlSection({Key? key, required this.editingViewModel, required this.height}) : super(key: key);

  @override
  State<_ItemsControlSection> createState() => _ItemsControlSectionState();
}

class _ItemsControlSectionState extends State<_ItemsControlSection> {
  late final EditingViewModel editingViewModel;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    editingViewModel = widget.editingViewModel;

    editingViewModel.selectedImageOutput.listen((i) {
      double imageIndex = (i).toDouble();

      scrollController.animateTo(
        imageIndex * (context.width*0.2) + ((context.width *0.02) * imageIndex),
        duration: const Duration(milliseconds: 850),
        curve: Curves.ease,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width*0.02),
      child: StreamBuilder(
          stream: editingViewModel.selectedImageOutput,
          builder: (context,selectedIndex) {
            final List<ImageModel> images = editingViewModel.imageList;

            return SizedBox(
                width: context.width,
                height: widget.height,
                child: Padding(
                    padding: EdgeInsets.only(right: context.width*0.02),
                    child: Row(
                      children: [
                        Expanded(
                          child: ReorderableListView.builder(
                             header: null,
                              onReorder: (oldIndex, newIndex) {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = editingViewModel.imageList.removeAt(oldIndex);
                                editingViewModel.imageList.insert(newIndex,item);
                                editingViewModel.changeSelectedImageIndex(newIndex);
                              },

                              scrollController: scrollController,
                              padding: EdgeInsets.symmetric(vertical:widget.height*0.09 ),
                              scrollDirection: Axis.horizontal,
                              itemCount: editingViewModel.imageList.length,

                              itemBuilder:(context, index) {
                                return GestureDetector(
                                  key: ValueKey(editingViewModel.imageList[index]),
                                  onTap: (){
                                    editingViewModel.changeSelectedImageIndex(index);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: context.width*0.02),
                                    child: Container(
                                      width: context.width*0.18,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          border: editingViewModel.selectedImageIndex == index
                                              ?Border.all(color: AppColors.primaryColor,width: 2)
                                              :null
                                      ),
                                      child: ClipRRect(
                                          borderRadius:BorderRadius.circular(15) ,
                                          child: Image.file(File(images[index].imageFile.path),fit: BoxFit.fill,)
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),

                        SizedBox(width: context.width*0.05,),

                        SizedBox(
                          width: context.width*0.13,
                          height: widget.height*0.5,

                          child: ElevatedButton(
                              style: getBorderedButtonStyle(bgColor: AppColors.bgColor,radius: 20),
                              onPressed:  (){
                                editingViewModel.pickGalleryImage();

                              },
                              child: const FittedBox(
                                child: Icon(
                                    Icons.add,
                                    color: AppColors.grey
                                ),
                              )

                          ),
                        ),


                      ],
                    )
                )

            );
          }),
    );
  }
}




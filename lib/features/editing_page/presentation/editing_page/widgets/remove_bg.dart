import 'dart:developer';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:lottie/lottie.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../reusable_components/pop_up_menu.dart';
import '../../../domain/entities/image_model.dart';
import '../view_model/editing_view_model.dart';
import 'package:image/image.dart' as img;
class RemoveBackground extends StatelessWidget {
  final ImageModel imageModel;
  final int index;
  final int feather;
  final EditingViewModel editingViewModel;

  const RemoveBackground({
    Key? key,
    required this.imageModel,
    this.feather = 0,
    required this.editingViewModel, required this.index
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _downloadImage(File(imageModel.imageFile.path)),
        builder:(context, snapshot) {
          if(snapshot.data==null){
            return _BuildLoadingWidget(imageModel:imageModel);
          }
            return StreamBuilder(
              stream: editingViewModel.removeBGFeatherOutput,
              builder: (context, values) {
                if(values.hasError){
                  Fluttertoast.showToast(msg: values.error.toString(),toastLength: Toast.LENGTH_SHORT);
                }else if(values.data == null){
                  //todo:do refactor
                 return _BuildImage(editingViewModel: editingViewModel,index: editingViewModel.selectedImageIndex,);
                }

                return FutureBuilder(
                      future: removeBackground(
                          context:context,
                          bytes:snapshot.data!,
                          red: editingViewModel.removeBGValue!.red,
                          green:editingViewModel.removeBGValue!.green,
                          blue: editingViewModel.removeBGValue!.blue,
                          feather: editingViewModel.removeBGValue!.feather
                      ),
                      builder:(context, snapshot1){
                        if(snapshot1.data==null ||snapshot1.connectionState == ConnectionState.waiting ){
                          return _BuildLoadingWidget(imageModel:imageModel);
                        }else{
                          editingViewModel.noBackgroundImage = snapshot1.data!;
                          return Stack(
                            children: [
                              Positioned(
                                  top: imageModel.top,
                                  left: imageModel.left,
                                  child: SizedBox(
                                      width: imageModel.width,
                                      height:imageModel.height,
                                      child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Image.memory(snapshot1.data!,)
                                      )
                                  )
                              )
                            ],
                          );
                        }
                      }
                  );

              },

            );
        }
      );

  }

  Future<Uint8List?> removeBackground({
    required Uint8List bytes,
    required int red,
    required int green,
    required int blue,
    required BuildContext context,
    int feather = 0
  }) async {
    img.Image? image = img.decodeImage(bytes);
    img.Image? transparentImage = await colorTransparent(
        src:image!,
        red:red,
        green:green,
        blue:blue,
        feather: feather
    );

    editingViewModel.changeBottomSheetState(true);
    var newPng = img.encodePng(transparentImage!);
    Uint8List unit8list = Uint8List.fromList(newPng);
    return unit8list;
  }

  Future<Uint8List> _downloadImage(File imageFile) async {
    File file =imageFile;
    var image = await file.readAsBytes();
    return image;
  }

  Future<img.Image?> colorTransparent({
    required img.Image src,
    required int red,
    required int green,
    required int blue,
    int feather = 0
  }) async {
    var bytes = src.getBytes();

    for (int i = 0, len = bytes.length; i < len; i += 4) {
      if(bytes[i] == red&&bytes[i+1] == green&&bytes[i+2] == blue){
        bytes[i + 3] = 0;
      }
      if(feather != 0){
        if((red >= bytes[i]&&bytes[i] >= (red-feather))
         ||(green >= bytes[i+1]&&bytes[i+1] >= (green-feather))
         ||(blue >= bytes[i+1]&&bytes[i+1] >= (blue-feather)) )
        {
          bytes[i + 3] = 0;
        }
      }
    }

    return img.Image.fromBytes(src.width, src.height, bytes);
  }
}

class _BuildLoadingWidget extends StatelessWidget {
  final ImageModel imageModel;
  const _BuildLoadingWidget({Key? key, required this.imageModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: imageModel.top,
            left: imageModel.left,
            child: Container(
                width: imageModel.width,
                height:imageModel.height,
                color: AppColors.lightGrey,
                alignment: Alignment.center,
                child: Lottie.asset("assets/lottie/image_process_loading.json", fit: BoxFit.scaleDown)
            )
        )
      ],
    );
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
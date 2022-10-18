import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ButtonStyle, Icons, TextStyle;
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/constants/app_icons.dart';
import 'package:image_manipulate/core/constants/app_strings.dart';
import 'package:image_manipulate/core/constants/app_styles.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import 'package:image_manipulate/core/utils/image_picker_helper.dart';
import 'package:image_manipulate/presentation/base/base_view_model.dart';
import 'package:image_picker/image_picker.dart';

class EditingViewModel extends BaseViewModel with EditingInputViewModel,EditingOutputViewModel{
  final ImagePickerHelper imagePickerHelper;
  EditingViewModel(this.imagePickerHelper);

  MainButtonsType mainButtonType = MainButtonsType.image;
  AttributeButtonType? attributeButtonType;
  int selectedImageIndex = 0;

  List<ImageModel> imageList = [];

  StreamController<List<MainButtonModel>> mainButtonController = StreamController();
  StreamController<List<AttributeButtonModel>> attributeButtonController = StreamController();
  StreamController<ImageModel> pickedImageController = StreamController();//todo:maybe remove this
  StreamController<int> selectedImageController = StreamController.broadcast();

  @override
  void start(XFile? image) {
    final initialImageModel = ImageModel(
        imageFile: image!,
        width: 0,
        height: 0,
        top: -4,
        left: 0
    );
    imageList.add(initialImageModel);

    pickedImageInput.add(initialImageModel);

    mainButtonsInput.add(_getMainButtons(mainButtonType));

    attributeButtonsInput.add(_getAttributeButtons());
    selectedImageInput.add(0);
  }

  @override
  void dispose() {
    mainButtonController.close();
    attributeButtonController.close();
    selectedImageController.close();
    pickedImageController.close();
  }

  Future<void> pickGalleryImage({bool isChangeImage = false}) async{
    try{
      final XFile? image = await imagePickerHelper.pickImageFromGallery();

      if(image==null) {
        selectedImageController.addError("image not picked");
      }else{
        final ImageModel imageModel;
        if(isChangeImage){
          imageModel = imageList[selectedImageIndex].copyWith(imageFile: image);
          imageList.removeAt(selectedImageIndex);
          imageList.insert(selectedImageIndex, imageModel);
        }else{
          imageModel = ImageModel(
              imageFile: image,
              width: 0,
              height: 0,
              top: -4,
              left: 0
          );
          imageList.add(imageModel);
          selectedImageIndex = imageList.length-1;
        }

        selectedImageInput.add(selectedImageIndex);
        pickedImageInput.add(imageModel);
      }

    }catch(e){
      log(e.toString());
      selectedImageController.addError("something went wrong,please try again");
    }
  }

  void deleteImage(){
    imageList.removeAt(selectedImageIndex);
    selectedImageIndex = selectedImageIndex - 1;
    if(selectedImageIndex < 0 && imageList.isNotEmpty){
      selectedImageIndex++;
    }
    selectedImageInput.add(selectedImageIndex);
  }

  void changeMainButtons(MainButtonsType type){
    if(type != mainButtonType){
      mainButtonType = type;
      mainButtonsInput.add(_getMainButtons(type));

      attributeButtonsInput.add(_getAttributeButtons());
    }
  }

  void changeAttributeButtons(AttributeButtonType type){
    if(type != attributeButtonType){
      attributeButtonsInput.add(_getAttributeButtons(type:type));
    }
  }

  void changeSelectedImageIndex(index){
    selectedImageIndex = index;
    selectedImageInput.add(index);
  }

  //private functions

  List<MainButtonModel> _getMainButtons(MainButtonsType type){
    TextStyle textStyle;
    ButtonStyle buttonStyle;

    return List.generate(
        MainButtonsType.values.length,
            (i){
          final buttonType = MainButtonsType.values[i];

          if(type == buttonType){
            textStyle = getRegularTextStyle(color: AppColors.white);
            buttonStyle = getRegularButtonStyle(bgColor: AppColors.primaryColor,radius: 25);
          }else{
            textStyle = getRegularTextStyle(color: AppColors.grey);
            buttonStyle = getRegularButtonStyle(bgColor: AppColors.white, radius: 25);
          }
          return MainButtonModel(
              title: _getMainButtonText(buttonType),
              type: buttonType,
              textStyle: textStyle,
              buttonStyle: buttonStyle
          );
        }
    );
  }

  String _getMainButtonText(MainButtonsType type){
    switch(type){
      case MainButtonsType.image: return AppStrings.image;
      case MainButtonsType.text: return AppStrings.text;
    }
  }

  List<AttributeButtonModel> _getAttributeButtons({AttributeButtonType? type}){
    TextStyle textStyle;
    ButtonStyle buttonStyle;
    Color iconColor;
    List<AttributeButtonType> types = _getAttributeButtonTypes();

    type ??= types[0];
    attributeButtonType = type;

    return List.generate(
        types.length, (i){

      if(type == types[i]){
        textStyle = getRegularTextStyle(color: AppColors.black);
        buttonStyle = getRegularSubButtonStyle(bgColor: AppColors.primaryColor);
        iconColor = AppColors.white;
      }else{
        textStyle = getRegularTextStyle(color: AppColors.grey);
        buttonStyle = getRegularSubButtonStyle(bgColor: AppColors.lightGrey);
        iconColor = AppColors.grey;
      }
      return AttributeButtonModel(
        title: _getAttributeButtonText(types[i]),
        textStyle: textStyle,
        buttonStyle: buttonStyle,
        iconColor: iconColor,
        type: types[i],
        icon: _getAttributeButtonIcon(types[i]),

      );
    }
    );
  }

  List<AttributeButtonType>_getAttributeButtonTypes(){
    final List<AttributeButtonType> types;

    if(mainButtonType == MainButtonsType.image) {
      types =[
        AttributeButtonType.resize,
        AttributeButtonType.crop,
        AttributeButtonType.blackAndWhite,
        AttributeButtonType.removeBg,
      ];
    }else{
      types =[
        AttributeButtonType.textSize,
        AttributeButtonType.fontFamily,
        AttributeButtonType.fontWeight,
        AttributeButtonType.textColor,
      ];
    }
    return types;
  }

  String _getAttributeButtonText(AttributeButtonType type){
    switch(type){
      case AttributeButtonType.textSize: return AppStrings.textSize;
      case AttributeButtonType.fontFamily: return AppStrings.fontFamily;
      case AttributeButtonType.fontWeight: return AppStrings.fontWeight;
      case AttributeButtonType.textColor: return AppStrings.textColor;

      case AttributeButtonType.resize: return AppStrings.resize;
      case AttributeButtonType.crop: return AppStrings.crop;
      case AttributeButtonType.blackAndWhite: return AppStrings.blackAndWhite;
      case AttributeButtonType.removeBg: return AppStrings.removeBg;
    }
  }

  IconData _getAttributeButtonIcon(AttributeButtonType type){
    switch(type){
      case AttributeButtonType.textSize: return AppIcons.fontSize;
      case AttributeButtonType.fontFamily: return AppIcons.fontFamily;
      case AttributeButtonType.fontWeight: return AppIcons.bold;
      case AttributeButtonType.textColor: return AppIcons.fontColor;

      case AttributeButtonType.resize: return AppIcons.resize;
      case AttributeButtonType.crop: return AppIcons.crop;
      case AttributeButtonType.blackAndWhite: return AppIcons.blackAndWhite;
      case AttributeButtonType.removeBg: return AppIcons.removeBG;
    }
  }

  //inputs
  @override
  Sink<List<MainButtonModel>> get mainButtonsInput => mainButtonController.sink;

  @override
  Sink<List<AttributeButtonModel>> get attributeButtonsInput => attributeButtonController.sink;

  @override
  Sink<int> get selectedImageInput => selectedImageController.sink;

  @override
  Sink<ImageModel> get pickedImageInput => pickedImageController.sink;

  //outputs
  @override
  Stream<List<MainButtonModel>> get mainButtonsOutput=> mainButtonController.stream;

  @override
  Stream<List<AttributeButtonModel>> get attributeButtonsOutput => attributeButtonController.stream;

  @override
  Stream<int> get selectedImageOutput => selectedImageController.stream;

  @override
  Stream<ImageModel> get pickedImageOutput => pickedImageController.stream;
}

abstract class EditingInputViewModel{
  Sink<List<MainButtonModel>> get mainButtonsInput;
  Sink<List<AttributeButtonModel>> get attributeButtonsInput;
  Sink<int> get selectedImageInput;
  Sink<ImageModel> get pickedImageInput;
}

abstract class EditingOutputViewModel{
  Stream<List<MainButtonModel>> get mainButtonsOutput;
  Stream<List<AttributeButtonModel>> get attributeButtonsOutput;
  Stream<int> get selectedImageOutput;
  Stream<ImageModel> get pickedImageOutput;
}

//models
class MainButtonModel{
  final String title;
  final MainButtonsType type;
  final ButtonStyle buttonStyle;
  final TextStyle textStyle;

  const MainButtonModel({
    required this.textStyle,
    required this.buttonStyle,
    required this.title,
    required this.type
  });
}

class AttributeButtonModel{
  final String title;
  final IconData icon;
  final TextStyle textStyle;
  final ButtonStyle buttonStyle;
  final Color iconColor;
  final AttributeButtonType type;

  AttributeButtonModel({
    required this.type,
    required this.icon,
    required this.title,
    required this.textStyle,
    required this.buttonStyle,
    required this.iconColor,
  });
}

class AddSectionModel{
  final List<String> titles;
  AddSectionModel({
    required this.titles,
  });
}

class ImageModel{
  XFile imageFile;
  double width;
  double height;
  double top;
  double left;

  ImageModel({
    required this.imageFile,
    required this.width,
    required this.height,
    required this.top,
    required this.left,
  });

  copyWith({
    XFile? imageFile,
    double? width,
    double? height,
    double? top,
    double? left,
  }){
    return ImageModel(
        left:left??this.left,
        top: top??this.top,
        height: height ?? this.height,
        width: width??this.width,
        imageFile: imageFile??this.imageFile
    );
  }
}

enum MainButtonsType{
  image,text
}

enum AttributeButtonType{
  textSize,
  fontFamily,
  fontWeight,
  textColor,

  resize,
  crop,
  blackAndWhite,
  removeBg
}

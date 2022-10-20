import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ButtonStyle, TextStyle;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/constants/app_icons.dart';
import 'package:image_manipulate/core/constants/app_strings.dart';
import 'package:image_manipulate/core/constants/app_styles.dart';
import 'package:image_manipulate/core/utils/image_picker_helper.dart';
import 'package:image_manipulate/features/editing_page/domain/entities/remove_bg_value.dart';
import 'package:image_manipulate/features/editing_page/presentation/base/base_view_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/attribute_button_model.dart';
import '../../../domain/entities/image_model.dart';
import '../../../domain/entities/main_button_model.dart';
import 'package:flutter/foundation.dart';

class EditingViewModel extends BaseViewModel with EditingInputViewModel,EditingOutputViewModel{
  final ImagePickerHelper imagePickerHelper;
  EditingViewModel(this.imagePickerHelper);

  MainButtonsType mainButtonType = MainButtonsType.image;
  AttributeButtonType? attributeButtonType;
  int selectedImageIndex = 0;
  RemoveBGValues? removeBGValue;
  Uint8List? noBackgroundImage;

  List<ImageModel> imageList = [];
  List<AttributeButtonModel> attributeButtons = [];

  StreamController<List<MainButtonModel>> mainButtonController = StreamController();
  StreamController<List<AttributeButtonModel>> attributeButtonController = StreamController.broadcast();
  StreamController<ImageModel> pickedImageController = StreamController();//todo:maybe remove this
  StreamController<int> selectedImageController = StreamController.broadcast();
  StreamController<bool> showBottomSheetController = StreamController();
  StreamController<RemoveBGValues> removeBGFeatherController = StreamController.broadcast();

  @override
  void start(XFile? image) {
    showBottomSheetInput.add(false);

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

    attributeButtons = _getAttributeButtons();
    attributeButtonsInput.add(attributeButtons);

    selectedImageInput.add(0);

  }

  @override
  void dispose() {
    mainButtonController.close();
    attributeButtonController.close();
    selectedImageController.close();
    pickedImageController.close();
    showBottomSheetController.close();
    removeBGFeatherController.close();
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

  Future<void> saveImage() async{
    //todo:refactor errros
    final File? savedImage = await imagePickerHelper.saveImage(
        noBackgroundImage!,
        imageList[selectedImageIndex].imageFile.path
    ).catchError((e,s){
      log(e.toString());
      Fluttertoast.showToast(msg: 'error, please try again');
    });

    if(savedImage == null){
      Fluttertoast.showToast(msg: 'failed to save the image, please try again');
    }else{
      imageList.replaceRange(
          selectedImageIndex,
          selectedImageIndex+1,
          [imageList[selectedImageIndex].copyWith(imageFile:XFile(savedImage.path))]
      );
    }
    log(imageList[selectedImageIndex].imageFile.path.toString());
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

      attributeButtons = _getAttributeButtons();
      attributeButtonsInput.add(attributeButtons);
    }
  }

  void changeBGRemoverFeather(int feather){
    if(removeBGValue != null){
      removeBGValue = removeBGValue!.copyWith(feather: feather);
      removeBGFeatherInput.add(removeBGValue!);
    }else{
      removeBGFeatherController.addError("You should remove the background first to use feather");
    }

  }

  void changeBGRemoverValues({required int red, required int green,required int blue,int? feather}){
      removeBGValue = RemoveBGValues(red: red, green: green, blue: blue, feather: feather??0);
      removeBGFeatherInput.add(removeBGValue!);
  }

  void changeBottomSheetState(bool isOpen){
    showBottomSheetInput.add(isOpen);
  }

  void changeAttributeButtons(AttributeButtonType type){
    if(type != attributeButtonType){
      attributeButtons = _getAttributeButtons(type:type);
      attributeButtonsInput.add(attributeButtons);
    }
  }

  void changeSelectedImageIndex(int index){
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

  @override
  Sink<bool> get showBottomSheetInput => showBottomSheetController.sink;

  @override
  Sink<RemoveBGValues> get removeBGFeatherInput => removeBGFeatherController.sink;

  //outputs
  @override
  Stream<List<MainButtonModel>> get mainButtonsOutput=> mainButtonController.stream;

  @override
  Stream<List<AttributeButtonModel>> get attributeButtonsOutput => attributeButtonController.stream;

  @override
  Stream<int> get selectedImageOutput => selectedImageController.stream;

  @override
  Stream<ImageModel> get pickedImageOutput => pickedImageController.stream;

  @override
  Stream<bool> get showBottomSheetOutput => showBottomSheetController.stream;

  @override
  Stream<RemoveBGValues> get removeBGFeatherOutput => removeBGFeatherController.stream;
}

abstract class EditingInputViewModel{
  Sink<List<MainButtonModel>> get mainButtonsInput;
  Sink<List<AttributeButtonModel>> get attributeButtonsInput;
  Sink<int> get selectedImageInput;
  Sink<ImageModel> get pickedImageInput;
  Sink<bool> get showBottomSheetInput;
  Sink<RemoveBGValues> get removeBGFeatherInput;
}

abstract class EditingOutputViewModel{
  Stream<List<MainButtonModel>> get mainButtonsOutput;
  Stream<List<AttributeButtonModel>> get attributeButtonsOutput;
  Stream<int> get selectedImageOutput;
  Stream<ImageModel> get pickedImageOutput;
  Stream<bool> get showBottomSheetOutput;
  Stream<RemoveBGValues> get removeBGFeatherOutput;
}

import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show basename;

class ImagePickerHelper{

  Future<XFile?> pickImageFromGallery() async{
    final ImagePicker picker = ImagePicker();
    return picker.pickImage(source: ImageSource.gallery);
  }

  Future<File?> saveImage(Uint8List image,String imagePath) async{
    //todo:add try catch
    final appDirectory = await getApplicationDocumentsDirectory();

    final String appDirectoryPath = appDirectory.path;

    final String imageBaseName = basename(imagePath);

    final newImage = await File("$appDirectoryPath/$imageBaseName").writeAsBytes(image);

    return newImage;
  }

}
import 'package:image_picker/image_picker.dart';

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
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper{

  Future<XFile?> pickImageFromGallery() async{
    final ImagePicker picker = ImagePicker();
    return picker.pickImage(source: ImageSource.gallery);
  }

}
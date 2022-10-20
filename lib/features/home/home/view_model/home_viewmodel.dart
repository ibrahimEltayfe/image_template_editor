import 'dart:async';
import 'dart:developer';
import 'package:image_manipulate/core/utils/image_picker_helper.dart';
import 'package:image_manipulate/features/editing_page/presentation/base/base_view_model.dart';
import 'package:image_picker/image_picker.dart';

class HomeViewModel extends BaseViewModel with HomeInputViewModel,HomeOutputViewModel{
  final ImagePickerHelper imagePickerHelper;
  HomeViewModel(this.imagePickerHelper);

  StreamController<XFile> imageStreamController = StreamController<XFile>();

  @override
  void start(image){}

  @override
  void dispose() {
    imageStreamController.close();
  }

  Future<void> pickGalleryImage() async{
    try{
      final XFile? image = await imagePickerHelper.pickImageFromGallery();

      if(image==null) {
         imageStreamController.addError("image not picked");
      }else{
        return imageInputViewModel.add(image);
      }

    }catch(e){
      log(e.toString());
      imageStreamController.addError("something went wrong,please try again");
    }
  }

  //inputs
  @override
  Sink<XFile> get imageInputViewModel => imageStreamController.sink;

  //outputs
  @override
  Stream<XFile> get imageOutputViewModel => imageStreamController.stream;

}

abstract class HomeInputViewModel{
 Sink<XFile> get imageInputViewModel;
}

abstract class HomeOutputViewModel{
 Stream<XFile> get imageOutputViewModel;
}
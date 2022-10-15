
import 'package:get_it/get_it.dart';
import 'package:image_manipulate/core/utils/image_picker_helper.dart';

var injector = GetIt.instance;

void init(){
  injector.registerLazySingleton<ImagePickerHelper>(() => ImagePickerHelper());
}
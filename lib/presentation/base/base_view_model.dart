import 'package:image_picker/image_picker.dart';

abstract class BaseViewModel{

  void start(XFile? image);
  void dispose();

}
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class RemoveBackground extends StatelessWidget {
  final int red;
  final int green;
  final int blue;
  final File imageFile;
  final int feather;

  const RemoveBackground({
    Key? key,
    required this.red,
    required this.green,
    required this.blue,
    required this.imageFile,
    this.feather = 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: FutureBuilder(
        future: _downloadImage(imageFile),
        builder:(context, snapshot) {
          if(snapshot.data==null){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else{
            return FutureBuilder(
              future: removeBackground(bytes:snapshot.data!,red:red,green:green,blue:blue,feather: feather),
              builder:(context, snapshot1) => snapshot1.data==null?Container():Container(
                child: Center(
                    child: Image.memory(snapshot1.data!,)
                ),
              ),
            );
          }
        }
      ),
    );
  }

  Future<Uint8List?> removeBackground({
    required Uint8List bytes,
    required int red,
    required int green,
    required int blue,
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

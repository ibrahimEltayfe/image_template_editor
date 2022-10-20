import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/utils/injector.dart' as di;

import 'features/home/home/view/home.dart';

void main() {
  di.init();
  runApp(
     DevicePreview(
       enabled: !kDebugMode,
       builder:(context) => MyApp()
     )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DevicePreview.appBuilder(context,
      MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        theme: ThemeData(
          bottomSheetTheme:const BottomSheetThemeData(
              backgroundColor: AppColors.white,
              elevation: 3,
              shape: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
            )
          )),
        ),
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        home: Home()
      ),
    );
  }
}


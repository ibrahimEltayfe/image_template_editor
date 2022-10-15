import 'package:flutter/material.dart';

extension MediaQueryConfig on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
}

extension DeviceWindowSize on double{
  double get fromDeviceWidth => MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * this;
  double get fromDeviceHeight => MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * this;

}

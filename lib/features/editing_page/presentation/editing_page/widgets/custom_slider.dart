import 'package:flutter/material.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/constants/app_styles.dart';

import '../../../../reusable_components/fittted_text.dart';
import '../view_model/editing_view_model.dart';

class CustomSlider extends StatefulWidget {
  final double width;
  final double height;
  final String label;
  final EditingViewModel editingViewModel;
  const CustomSlider({Key? key, required this.width, required this.height, required this.editingViewModel, required this.label}) : super(key: key);

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        children: [
          FittedText(
            height: widget.height,
            width: widget.width*0.17,
            text:widget.label,
            textStyle: getRegularTextStyle(),
          ),
          Expanded(
            child: Slider(
              value: value,
              label: value.toString(),
              onChanged: (newVal) {
                setState(() {
                  value = newVal;
                });
              },
              onChangeEnd: (value) {
                widget.editingViewModel.changeBGRemoverFeather(value.toInt());
              },
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.lightGrey,
              autofocus: true,
              divisions: 60,
              min: 0,
              max:60,
            ),
          ),
        ],
      ),
    );
  }
}

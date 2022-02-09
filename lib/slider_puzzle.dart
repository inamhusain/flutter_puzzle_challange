import 'package:flutter/material.dart';
import 'package:flutter_slider_puzzle/utils.dart';

class SliderPuzzle extends StatelessWidget {
  // double valueSlider = 2;
  final ValueNotifier<double> valueSlider = ValueNotifier<double>(2);

  SliderPuzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.lightPurple,
        body: Container(
          height: height,
          width: double.maxFinite,
          color: AppColors.lightPurple,
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: valueSlider,
                builder: (context, value, child) {
                  return Text(
                      'Slider Puzzle ${valueSlider.value.round()}x${valueSlider.value.round()}');
                },
              ),
              Container(),
              ValueListenableBuilder(
                valueListenable: valueSlider,
                builder: (context, value, child) {
                  return Slider(
                    min: 2,
                    max: 15,
                    divisions: 13,
                    activeColor: AppColors.strongDarkPurple,
                    inactiveColor: AppColors.white,
                    thumbColor: AppColors.strongDarkPurple,
                    label: "${valueSlider.value.round()}",
                    value: valueSlider.value,
                    onChanged: (value) {
                      valueSlider.value = value;
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

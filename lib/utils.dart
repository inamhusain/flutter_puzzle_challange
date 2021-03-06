// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';

class Utils {
  static ratioSize(context, size) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return (height / 100 * width / 100) / 10 * size;
  }
}

class AppColors {
  static Color purple = Color(0xff7C80EE);
  static Color lightPurple = Color(0XFFede8f9);
  static Color darkPurple = Color(0xff696a92);
  static Color strongDarkPurple = Color(0xff20124d);
  static Color black = Colors.black;
  static Color white = Colors.white;
}

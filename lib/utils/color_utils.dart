import 'package:flutter/material.dart';

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

class Palette {
  static const Color neonGreen = Color(0xFF51ca98);
  static const Color neonBlue = Color(0xFF00c6fb);
  static const Color neonRed = Color(0xFFfe3577);
  static const Color neonPurple = Color(0xffe233ff);

  static const Color blueGray = Color(0xFF1a3045);
  static const Color blueGrayDark = Color(0xFF142637);
  // pair
  static const Color blueAccent = Color(0xff23b6e6);
  static const Color greenAccent = Color(0xff02d39a);
  // pair
  static const Color orangeAccent = Color(0xffff930f);
  static const Color yellowAccent = Color(0xfffff95b);
  // pair
  static const Color redAccent = Color(0xffff5858);
  static const Color purpleAccent = Color(0xffc644fc);
  static const Color maroonAccent = Color(0xff730000);

  static const Color middleBlue = Color(0xff7ed6df);
  static const Color greenLandGreen = Color(0xff22a6b3);

  static const Color helioTrope = Color(0xffe056fd);
  static const Color steelPink = Color(0xffbe2edd);

  static const Color quinceJelly = Color(0xfff0932b);
  static const Color carminePink = Color(0xffeb4d4b);

  static const Color lightGray = Color(0xffdfe6e9);
}

import 'package:flutter/material.dart';
import 'package:new_app2/utils/color_utils.dart';

Image logoWidget(String path) {
  return Image.asset(
    path,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: const Color(0xff3c6382),
    style: TextStyle(color: hexStringToColor('#0a3d62')),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: const Color(0xff3c6382),
      ), // Icon
      labelText: text,
      labelStyle: TextStyle(color: hexStringToColor('#0a3d62')),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color(0xff3c6382).withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

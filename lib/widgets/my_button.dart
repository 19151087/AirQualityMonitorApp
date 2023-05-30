import 'package:flutter/material.dart';
import 'package:new_app2/utils/color_utils.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    // return GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     padding: const EdgeInsets.all(25),
    //     margin: const EdgeInsets.symmetric(horizontal: 25),
    //     decoration: BoxDecoration(
    //       color: Colors.black,
    //       borderRadius: BorderRadius.circular(8),
    //     ),
    //     child: Center(
    //       child: Text(
    //         text,
    //         style: const TextStyle(
    //           color: Colors.white,
    //           fontWeight: FontWeight.bold,
    //           fontSize: 16,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
        onPressed: () {
          onTap!();
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black26;
              }
              return hexStringToColor("0a3d62");
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)))),
        child: Text(
          text,
          style: const TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
    );
  }
}

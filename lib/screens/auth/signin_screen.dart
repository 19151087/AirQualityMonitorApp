import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/widgets/my_button.dart';
import 'package:new_app2/widgets/reusable_widget.dart';
import 'package:new_app2/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  final Function()? onTap;
  const SignInScreen({super.key, required this.onTap});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  Row signUpOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Don't have an account?",
            style: TextStyle(color: Color(0xff3c6382))),
        GestureDetector(
          onTap: widget.onTap,
          child: const Text(
            " Sign Up",
            style: TextStyle(
                color: Color(0xff0a3d62), fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // sign user in method
  void signIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // wrong email message popup
    void wrongEmailMessage() {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Color(0xff60a3bc),
            title: Center(
              child: Text(
                'Incorrect Email',
                style: TextStyle(color: Color(0xff0a3d62)),
              ),
            ),
          );
        },
      );
    }

    // wrong email message popup
    void badlyEmailMessage() {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Color(0xff60a3bc),
            title: Center(
              child: Text(
                'Badly formatted Email',
                style: TextStyle(color: Color(0xff0a3d62)),
              ),
            ),
          );
        },
      );
    }

    // wrong password message popup
    void wrongPasswordMessage() {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Color(0xff60a3bc),
            title: Center(
              child: Text(
                'Incorrect Password',
                style: TextStyle(color: Color(0xff0a3d62)),
              ),
            ),
          );
        },
      );
    }

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );
      // pop the loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // WRONG EMAIL
      if (e.code == 'user-not-found') {
        // show error to user
        wrongEmailMessage();
        print("ERROR : ${e.code.toString()}");
      }
      // BADLY FORMATTED EMAIL
      else if (e.code == 'invalid-email') {
        // show error to user
        badlyEmailMessage();
        print("ERROR : ${e.code.toString()}");
      }
      // WRONG PASSWORD
      else if (e.code == 'wrong-password') {
        // show error to user
        wrongPasswordMessage();
        print("ERROR : ${e.code.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("60a3bc"),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover),
          color: Color.fromRGBO(14, 51, 17, 0.2),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/apple-touch-icon.png"),
                const SizedBox(height: 20),
                Text("Air Quality Monitor",
                    style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: hexStringToColor('#0a3d62'))),
                Text("Healthy life, happy life!",
                    style: GoogleFonts.montserrat(
                        fontSize: 15, color: hexStringToColor('#0a3d62'))),
                const SizedBox(height: 30),
                reusableTextField("Enter UserName", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 20),
                MyButton(onTap: signIn, text: 'SIGN IN'),
                // authButton(context, 'SIGN IN', () {
                //   FirebaseAuth.instance
                //       .signInWithEmailAndPassword(
                //           email: _emailTextController.text,
                //           password: _passwordTextController.text)
                //       .then((value) {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => const HomeScreen()));
                //   }).onError((error, stackTrace) {
                //     print("ERROR : ${error.toString()}");
                //   });
                // }),
                signUpOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

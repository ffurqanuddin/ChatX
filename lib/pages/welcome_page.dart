import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/pages/auth/login_page.dart';
import 'package:chatx/pages/auth/sign_up_page.dart';
import 'package:chatx/resources/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(bottom: 5.h, top: 10.h),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Logo Animation
              const _logo(),

              //Description
              Column(
                children: [
                  const AutoSizeText(
                    "Welcome",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 35,
                      color: Colors.black
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  AnimatedTextKit(
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TypewriterAnimatedText(
                          'Share your feelings fast and secure!',
                          textStyle: GoogleFonts.abel(fontSize: 19.sp, color: Colors.black),
                          speed: const Duration(
                            milliseconds: 70,
                          ),
                          curve: Curves.bounceIn),
                    ],
                    totalRepeatCount: 4,
                    pause: const Duration(milliseconds: 1000),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),
                  //Buttons
                  Container(
                    width: 85.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.transparent, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 0),
                            blurRadius: 5,
                          )
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Register Button
                        _Buttons(
                            onTap: () {
                           Helper.naviagteToScreen(const SignUpPage(), context);
                            },
                            title: "Register",
                            titleColor: Colors.black,
                            buttonColor: Colors.white,
                            topLeft: 20,
                            bottomLeft: 20,
                            topRight: 0,
                            bottomRight: 0),

                        //Login Button
                        _Buttons(
                            onTap: () {
                              Helper.naviagteToScreen(const LoginPage(), context);
                            },
                            title: "Login",
                            titleColor: Colors.white,
                            buttonColor: Colors.black,
                            topLeft: 0,
                            bottomLeft: 0,
                            topRight: 20,
                            bottomRight: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}


////////////////////////////////////////////////
/////////////***Custom Widgets***/////////////////////
///////////////////////////////////////////////
//***Logo***//
class _logo extends StatelessWidget {
  const _logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 60.w,
        width: 60.w,
        child: Stack(
          children: [
            //Logo
            Lottie.asset(
              Assets.logo,
            ),
            //Title
            Positioned(
              bottom: 1.h,
              left: 16.w,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: "Chat", style: TextStyle(fontSize: 26.sp, color: Colors.black)),
                  TextSpan(
                      text: "X",
                      style: TextStyle(
                          fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.black))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//***Custom Button//
class _Buttons extends StatelessWidget {
  const _Buttons({
    this.onTap,
    required this.buttonColor,
    required this.title,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.titleColor,
  });

  final onTap;
  final Color buttonColor;
  final Color titleColor;
  final String title;
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 8.h,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft),
              bottomLeft: Radius.circular(bottomLeft),
              bottomRight: Radius.circular(bottomRight),
              topRight: Radius.circular(topRight),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(color: titleColor),
          ),
        ),
      ),
    );
  }
}

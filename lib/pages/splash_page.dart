import 'package:chatx/pages/welcome_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../api/api.dart';
import '../helper/helper.dart';
import '../resources/assets.dart';
import 'home/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () async {
        try {
          if (APIs.auth.currentUser != null) {
            Helper.navigateReplaceToScreen(const HomePage(), context);
          } else {
            Helper.navigateReplaceToScreen(const WelcomePage(), context);
          }
        } catch (error) {
          print("Splash Screen : ... \n $error");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 100.h,
        child: Stack(
          alignment: Alignment.center,
          children: [

            Center(
              child: SizedBox(
                height: 40.h,
                child: Lottie.asset(
                  Assets.logo,
                ),
              ),
            ),

            //Title
            Positioned(
              top: 58.h,
              child: Center(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: "Chat",
                        style: TextStyle(fontSize: 26.sp, color: Colors.white)),
                    TextSpan(
                        text: "X",
                        style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

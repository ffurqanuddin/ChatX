import 'dart:async';
import 'package:chatx/api/api.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/pages/home/home_page.dart';
import 'package:chatx/resources/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../helper/dialogs.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({
    Key? key,
  }) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  int _counter = 120;

  /// Decrement the counter by 1 every second until it reaches 0.
  void _counterMinus() {
    if (_counter > 0) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_counter > 0) {
          setState(() {
            _counter -= 1;
          });
        } else {
          setState(() {
            timer.cancel();
            _counter = 0;
          });
        }
      });
    }
  }

  /// Check user's email verification status periodically.
  Future<void> checkVerification() async {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      try {
        setState(() {
          APIs.cuser.reload();
        });
        if (APIs.cuser.emailVerified) {
          setState(() {
            timer.cancel();
          });
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    /// Initialize the counter text and start counting down.
    _counterMinus();

    /// Periodically check the email verification status.
    checkVerification();
  }

  @override
  void dispose() {
    super.dispose();

    /// Stop the counter and email verification check.
    _counterMinus();
    checkVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
      ),
      body: StreamBuilder<User?>(
        stream: APIs.auth.authStateChanges(),
        builder: (context, snapshot) {
          /// Check if the user's email is verified and navigate to the home page.
          if (snapshot.data?.emailVerified == true) {
            Helper.navigateReplaceToScreen(const HomePage(), context);
          }

          /// UI
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Lottie animation to show an email inbox icon.

              Padding(
                padding:  EdgeInsets.all(10.w),
                child: LottieBuilder.asset(Assets.checkEmailInbox),
              ),

              SizedBox(height: 1.h,),
              /// Text to instruct the user to check their email inbox.
              Text(
                "Check Email Inbox",
                style: GoogleFonts.abel(fontSize: 20.sp),
              ),

              SizedBox(height: 10.h,),

              /// CircleAvatar to display the current counter value.
              Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text(_counter.toString(), style: const TextStyle(color: Colors.white),),
                ),
              ),

              SizedBox(height: 2.h,),
              ///Resend Button
             Visibility(
               visible: _counter.toString() == "0",
               child: GestureDetector(
                 onTap: (){
                   setState(() {
                     _counter = 60;
                     _counterMinus();
                     ///Resend Email Verification
                     APIs.auth.currentUser?.sendEmailVerification();

                     ///show snackbar
                     Dialogs.showSnackbar(msg: "email verification is successfully sent!", color: Colors.black, msgColor: Colors.white);
                   });

                 },
                 child: Container(
                   padding: EdgeInsets.all(2.h),
                   decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),child:  const Text("Resend email verification", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),),
               ),
             )
            ],
          );
        },
      ),
    );
  }
}

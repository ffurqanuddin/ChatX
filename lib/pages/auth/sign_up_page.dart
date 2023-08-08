import 'dart:developer';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatx/api/api.dart';
import 'package:chatx/helper/dialogs.dart';
import 'package:chatx/main.dart';
import 'package:chatx/pages/auth/EmailVerificationPage.dart';
import 'package:chatx/pages/auth/login_page.dart';
import 'package:chatx/pages/home/home_page.dart';
import 'package:chatx/resources/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../widgets/customFormField.dart';
import '../../widgets/custom_auth_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //***SignUp Section***//
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final signupUsername = TextEditingController();
  final signupEmail = TextEditingController();
  final signupPassword = TextEditingController();
  final FocusNode _signupUsernameFocus = FocusNode();
  final FocusNode _signupEmailFocus = FocusNode();
  final FocusNode _signupPasswordFocus = FocusNode();

  ///Show Password/Hide on Eye-Button
  bool obscurePassword = true;

  ///Button Circular-Progress-Indicator
  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    signupUsername.dispose();
    signupEmail.dispose();
    signupPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      ///APPBAR///
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,

      ///BODY
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///***Header Section***//
                SizedBox(
                  height: 25.h,
                  child: Lottie.asset(Assets.signup),
                ),

                ///Username
                CustomFormField(
                  controller: signupUsername,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  hintText: "Please enter your name",
                  prefixIcon: Icon(
                    MdiIcons.faceMan,
                  ),
                  validator: (val) {
                    if (val.toString().isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  focusnode: _signupUsernameFocus,
                  onFieldSubmitted: (_) {
                    // Move focus to the next field when the user taps "Next" on the keyboard
                    FocusScope.of(context).requestFocus(_signupEmailFocus);
                    _signupUsernameFocus.unfocus();
                  },
                  //Empty
                  suffix: const Text(""),
                ),

                ///Email
                CustomFormField(
                  controller: signupEmail,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  hintText: "Please enter your email",
                  prefixIcon: Icon(
                    MdiIcons.email,
                  ),
                  validator: (val) {
                    if (kDebugMode) {
                      print('Signup Email Validator called with value: $val');
                    }
                    if (val.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!val.toString().contains("@") &&
                        !val.toString().contains(".com")) {
                      return "Invalid email address";
                    }
                    return null;
                  },
                  focusnode: _signupEmailFocus,
                  onFieldSubmitted: (_) {
                    // Move focus to the next field when the user taps "Next" on the keyboard
                    FocusScope.of(context).requestFocus(_signupPasswordFocus);
                  },
                  //Empty
                  suffix: const Text(""),
                ),

                ///Password
                CustomFormField(
                  controller: signupPassword,
                  keyboardType: TextInputType.text,
                  obscureText: obscurePassword,
                  hintText: "Please enter a password",
                  prefixIcon: Icon(
                    MdiIcons.fingerprint,
                  ),
                  validator: (val) {
                    if (val.toString().isEmpty) {
                      return "Please enter a password";
                    }
                    if (val.toString().length < 8) {
                      return "Password must be 8 characters long";
                    }
                    if (val.toString().contains("12345678") ||
                        val.toString().contains("00000000")) {
                      return "Too easy, password must be strong";
                    }
                    return null;
                  },
                  focusnode: _signupPasswordFocus,
                  onFieldSubmitted: (_) {
                    // When the user taps "Done" on the keyboard, remove focus from the last field
                    _signupPasswordFocus.unfocus();
                  },
                  //Show Password/ obscure false
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: obscurePassword
                          ? Icon(MdiIcons.eye)
                          : Icon(MdiIcons.eyeCircleOutline)),
                ),

                SizedBox(
                  height: 4.h,
                ),

                ///***SIGNUP BUTTON***///
                CustomAuthButton(
                    onTap: () async {
                      await handleSignUp(
                          emailController: signupEmail,
                          passwordController: signupPassword,
                          formKey: _formKey);
                    },
                    child: const AutoSizeText(
                      "Signup",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    )),

                SizedBox(
                  height: 3.h,
                ),

                ///***SIGNUP WITH GOOGle***///
                CustomAuthButton(
                    onTap: () {
                      _handleGoogleBtnClick();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AutoSizeText(
                          "Signup with",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Icon(
                          MdiIcons.google,
                          color: Colors.white,
                        )
                      ],
                    )),

                SizedBox(
                  height: 4.h,
                ),

                ///Already have a account
                GestureDetector(
                  //OnTap
                  onTap: () {
                    _navigateToScreen(const LoginPage());
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      "Already have a account?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////
  /////////////***METHODS***/////////////////////
  ///////////////////////////////////////////////

  ///HandleSignUp Button///
  Future<void> handleSignUp(
      {required emailController,
      required passwordController,
      required formKey}) async {
    assert(emailController != null);

    ///Form is validate
    if (formKey.currentState!.validate()) {
      ///show circular progress dialog
      Dialogs.showCircularProgressBar(context);

      try {
        final String email = emailController.text.trim();
        final String password = passwordController.text.trim();

        UserCredential userCredential =
            await APIs.auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        ///If Sucessfully signup then Globally declare UserName will be assigned to (username entered through textfield by user)
        setState(() {
          UserName = signupUsername.text.trim();
        });

        ///Store Data into firesstore
        APIs.createUser();

        // User is successfully signed up
        log('\nUser signed up with UID: ${userCredential.user?.uid}');

        ///For closing circular progress indicator dialog
        Navigator.pop(context);

        ///Send Email Verification
        _sendEmailVerification(context);

        ///Navigate to Home Screen
        _navigateToScreen(const EmailVerificationPage());


      }

      ///on Erros
      on FirebaseAuthException catch (e) {
        ///For closing circular progress indicator dialog
        Navigator.pop(context);

        if (e.code == 'email-already-in-use') {
          // The email address is already registered
          log('\nThe email address is already registered.');
          Dialogs.showSnackbar(
              msg: "email-already registered, goto Login Page");
        } else if (e.code == 'weak-password') {
          // The password provided is too weak
          log('\nThe password provided is too weak.');
          Dialogs.showSnackbar(msg: "weak password");
        } else {
          // Handle other errors
          Dialogs.showSnackbar(msg: "${e.message}");
        }
      }
    }
  }

  ///***Navigate to Screen Helper Function***///
  void _navigateToScreen(page) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ));
  }

  ///Handle Google Sign_in
  _handleGoogleBtnClick() {
    ///Showing Progress Bar
    Dialogs.showCircularProgressBar(context);
    _signInWithGoogle().then((user) async {
      ///Hiding Progress Bar
      Navigator.pop(context);

      if (user != null) {
        await APIs.createUser();
        log('\n User: ${user.user}');
        log('\n Additional User Info: ${user.additionalUserInfo}');


        ///Naviagte To Home Screen
        _navigateToScreen(const HomePage());
      }
    });
  }

  ///Google Sign In
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (err) {
      log("\n_signInWithGoogle : $err");

      ///Error Snackbar
      Dialogs.showSnackbar(
          msg: "Something went wrong, check internet connection!",
          color: Colors.red);
    }
    return null;
  }

  ///Email Verification
  Future<void> _sendEmailVerification(BuildContext context) async {
    try {
      User? user = APIs.cuser;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        Dialogs.showSnackbar(
            msg: "Verification email sent",
            msgColor: Colors.white,
            color: Colors.green);
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }
}

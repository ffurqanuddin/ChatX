import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/pages/auth/forget_password_page.dart';
import 'package:chatx/pages/auth/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../api/api.dart';
import '../../helper/dialogs.dart';
import '../../resources/assets.dart';
import '../../widgets/customFormField.dart';
import '../../widgets/custom_auth_button.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //***Login Section***//
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loginEmail = TextEditingController();
  final loginPassword = TextEditingController();
  final FocusNode _loginEmailFocus = FocusNode();
  final FocusNode _loginPasswordFocus = FocusNode();

  ///Show Password/Hide on Eye-Button
  bool obscurePassword = true;

  ///Button Circular-Progress-Indicator
  bool isLoading = false;



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    loginEmail.dispose();
    loginPassword.dispose();
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
                  child: Lottie.asset(Assets.login),
                ),

                ///Email
                CustomFormField(
                  controller: loginEmail,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  hintText: "Please enter your email",
                  prefixIcon: Icon(
                    MdiIcons.email,
                  ),
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!val.toString().contains("@") &&
                        !val.toString().contains(".com")) {
                      return "Invalid email address";
                    }
                    return null;
                  },
                  focusnode: _loginEmailFocus,
                  onFieldSubmitted: (_) {
                    // Move focus to the next field when the user taps "Next" on the keyboard
                    FocusScope.of(context).requestFocus(_loginPasswordFocus);
                  },
                  //Empty
                  suffix: const Text(""),
                ),

                ///Password
                CustomFormField(
                  controller: loginPassword,
                  keyboardType: TextInputType.text,
                  obscureText: obscurePassword,
                  hintText: "Please enter a password",
                  prefixIcon: Icon(
                    MdiIcons.fingerprint,
                  ),
                  validator: (val) {
                    if (val
                        .toString()
                        .isEmpty) {
                      return "Please enter a password";
                    }
                    return null;
                  },
                  focusnode: _loginPasswordFocus,
                  onFieldSubmitted: (_) {
                    // When the user taps "Done" on the keyboard, remove focus from the last field
                    _loginPasswordFocus.unfocus();
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

                ///Forget Password
                GestureDetector(
                  onTap: (){
                    Helper.naviagteToScreen(const ForgotPasswordPage(), context);
                  },
                  child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: AutoSizeText(
                          "Forget Password",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )),
                ),

                SizedBox(
                  height: 4.h,
                ),

                ///***LOGIN BUTTON***///
                CustomAuthButton(
                    onTap: () {
                      handleLogin(emailController: loginEmail,
                          passwordController: loginPassword,
                          formKey: _formKey);
                    },
                    child: const AutoSizeText(
                      "Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    )),

                SizedBox(
                  height: 3.h,
                ),

                ///***LOGIN WITH GOOGlE***///
                CustomAuthButton(
                    onTap: () {

                      ///Login with Google
                      _handleGoogleBtnClick();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AutoSizeText(
                          "Login with",
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

                ///Create a new account
                GestureDetector(
                  //OnTap
                  onTap: () {
                    _navigateToScreen(const SignUpPage());
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AutoSizeText.rich(
                      TextSpan(text: "Not a member?",style: TextStyle(color: Colors.black), children: [

                        TextSpan(
                            text: " Register Now",
                            style: TextStyle(color: Colors.blue))
                      ]),
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

  ///Handle Login Button///
  Future<void> handleLogin({required emailController,
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
        await APIs.auth.signInWithEmailAndPassword(
            email: email, password: password);



        // User is successfully signed up
        log('\nUser signed up with UID: ${userCredential.user?.uid}');


        ///For closing circular progress indicator dialog
        Navigator.pop(context);


        /// Navigate to home page after successful Login
        _navigateToScreen(const HomePage());
      }

      ///on Erros
      on FirebaseAuthException catch (e) {

        Dialogs.showSnackbar(msg: "${e.message}");

        ///For closing Circular Progress Dialog
        Navigator.pop(context);
      }
    } else{
      Dialogs.showSnackbar(msg: "Please fill the Fields correctly",color: Colors.red, msgColor: Colors.white);
    }
  }


  ///Handle Google Sign_in
  _handleGoogleBtnClick() {
    ///Showing Progress Bar
    Dialogs.showCircularProgressBar(context);
    _signInWithGoogle().then((user) async {
      ///Hiding Progress Bar
      Navigator.pop(context);

      if (user != null) {
        ///If user exists, execute this code
        if (await APIs.userExists()) {
          log('\n User: ${user.user}');
          log('\n Additional User Info: ${user.additionalUserInfo}');

          ///Naviagte To Home Screen
          _navigateToScreen(const HomePage());
        }

        ///If user does'nt exists then execute this code
        else {
          await APIs.createUser();
          log('\n User: ${user.user}');
          log('\n Additional User Info: ${user.additionalUserInfo}');




          ///Naviagte To Home Screen
          _navigateToScreen(const HomePage());
        }
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


  ///Navigate to Screen
  void _navigateToScreen(page) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ));
  }

}





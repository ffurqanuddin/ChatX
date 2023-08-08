import 'package:chatx/api/api.dart';
import 'package:chatx/pages/auth/login_page.dart';
import 'package:chatx/resources/assets.dart';
import 'package:chatx/widgets/customFormField.dart';
import 'package:chatx/widgets/custom_auth_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../helper/dialogs.dart';
import '../../helper/helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(

            children: [

              ///Header Image
              SizedBox(
                height: 35.h,
                child: LottieBuilder.asset(Assets.forgetPassword),
              ),



              ///Email Field
              CustomFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  hintText: "Enter your email",
                  prefixIcon: Icon(MdiIcons.emailVariant),
                  focusnode: emailFocusNode,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },

                  ///Its required parameter, that's why i fill with empty text
                  suffix: const Text("")),

              SizedBox(
                height: 3.h,
              ),

              ///Reset Button
              CustomAuthButton(
                onTap:  _handleForgotPassword,
                child: Text(
                        'Reset Password',
                        style: TextStyle(color: Colors.white, fontSize: 17.sp),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///HandleForgotPassword
  Future<void> _handleForgotPassword() async {
    if (_formKey.currentState!.validate()) {


      try {
        final String email = _emailController.text.trim();

        await APIs.auth.sendPasswordResetEmail(email: email);

        // Password reset email sent successfully
        if (kDebugMode) {
          print('Password reset email sent to $email');
        }
        Dialogs.showSnackbar(msg: "A password reset email has been sent to your email address.", color: Colors.green, msgColor: Colors.white);



        ///Navigate previous page After successfully send reset password verification
        Helper.navigateReplaceToScreen(const LoginPage(), context);

      } on FirebaseAuthException catch (e) {
        setState(() {
        });

        if (e.code == 'user-not-found') {
          // The email address is not registered
          Dialogs.showSnackbar(msg: "No user found with this email address.", color: Colors.red, msgColor: Colors.white);
          print('No user found with this email address.');
        } else {
          // Handle other errors
          print('Error: ${e.message}');
          Dialogs.showSnackbar(msg: e.message, color: Colors.red, msgColor: Colors.white);
        }
      }
    }
  }

}

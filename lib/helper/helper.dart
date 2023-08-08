



import 'package:flutter/material.dart';

class Helper{
  ///Navigate to next screen
  static navigateReplaceToScreen(page, context){
    return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page,));
  }

  ///Navigate to next screen
 static naviagteToScreen(page, context){
   return Navigator.push(context, MaterialPageRoute(builder: (context) => page,));
 }
}
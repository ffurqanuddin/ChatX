import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Dialogs{
  ///Circular Progress bar
  static void showCircularProgressBar(context){
    showDialog(context: context, builder: (_) => const Center(child:  CupertinoActivityIndicator(
    color: Colors.white,
    ),),);
  }

  /// Flutter Snackbar
 static void showSnackbar({final msg, final color, final msgColor}){
    Fluttertoast.showToast(msg: msg,backgroundColor: color,textColor: msgColor);
 }
}
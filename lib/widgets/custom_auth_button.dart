// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomAuthButton extends StatefulWidget {
   CustomAuthButton(
      {super.key, this.onTap, required this.child,this.btnColor = Colors.black} );

  final onTap;
  final Widget child;
  final Color btnColor;

  @override
  State<CustomAuthButton> createState() => _CustomAuthButtonState();
}

class _CustomAuthButtonState extends State<CustomAuthButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 7.h,
          width: 75.w,
          decoration: BoxDecoration(
            color: widget.btnColor,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child:widget.child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField(
      {this.validator,
      required this.controller,
      required this.keyboardType,
      required this.obscureText,
      this.onTap,
      super.key,
      required this.hintText,
      required this.prefixIcon,
      required this.focusnode,
      this.onFieldSubmitted,
      required this.suffix});

  final validator;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final onTap;
  final String hintText;
  final Icon prefixIcon;
  final FocusNode focusnode;
  final onFieldSubmitted;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10),boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0, 0),blurRadius: 12,spreadRadius: 1)]),
      child: TextFormField(
        validator: validator,
        controller: controller,
        onTapOutside: (event) => FocusManager.instance.primaryFocus!.unfocus(),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: (value) {
          value = controller.text;
        },
        onTap: onTap,
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffix,
            errorStyle: TextStyle(color: Colors.white,overflow: TextOverflow.ellipsis),
            errorMaxLines: 1,

            border: InputBorder.none,
            hintStyle: TextStyle(
                color: Colors.grey.shade500, fontWeight: FontWeight.w400),
            suffixIconColor: Colors.grey.shade400),
        focusNode: focusnode,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}

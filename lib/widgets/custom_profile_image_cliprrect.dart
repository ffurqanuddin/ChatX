import 'package:flutter/cupertino.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

///Profile Image Custom ClipRRect
class ProfileImageClipRRect extends StatelessWidget {
  const ProfileImageClipRRect({super.key, required this.child});

  final child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50.h),
            bottomRight: Radius.circular(50.h)),
        child: child);
  }
}
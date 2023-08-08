import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../resources/assets.dart';

class CallsTab extends StatefulWidget {
  const CallsTab({super.key});

  @override
  State<CallsTab> createState() => _CallsTabState();
}

class _CallsTabState extends State<CallsTab> {
  @override
  Widget build(BuildContext context) {
    return  Expanded(
      child: Column(
        children: [
          SizedBox(height: 15.h,),
          SizedBox(
              width: 90.w,
              child: Lottie.asset(Assets.codding)),
          SizedBox(height: 2.h,),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 20.0,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('App under development.'),
                WavyAnimatedText('Keep calm & Stay tuned!'),
              ],
              isRepeatingAnimation: true,
              onTap: () {

              },
            ),
          ),
        ],
      ),
    );
  }
}

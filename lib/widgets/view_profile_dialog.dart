import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class ViewProfileDialog extends StatelessWidget {
   ViewProfileDialog({super.key, required this.user});

  ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [
        Text(user.name.toString(), style: TextStyle(fontSize: 19.sp),),
        if(user.verified == true)const Icon(Icons.verified_rounded, color: Colors.white,),
        const Spacer(),
        if(user.email == "ffurqanuddin@gmail.com")Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MdiIcons.androidStudio),
            Text("""Developer""",softWrap: true,textAlign: TextAlign.center,maxLines: 2, style: TextStyle(color: Colors.white, fontSize: 11.sp),),
          ],
        )
      ],),
      content: CachedNetworkImage(imageUrl: user.image.toString()),
     contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.symmetric(vertical: 02.h, horizontal: 05.w),
    );
  }
}

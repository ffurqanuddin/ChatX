import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../models/chat_user.dart';

// ignore: must_be_immutable
class ViewProfileImage extends StatefulWidget {
  ViewProfileImage(
      {super.key,
      required this.user,
      required this.loadPalette,
      required this.paletterGenerator});

  ChatUser user;
  final loadPalette;
  final paletterGenerator;

  @override
  State<ViewProfileImage> createState() => _ViewProfileImageState();
}

class _ViewProfileImageState extends State<ViewProfileImage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title:

            ///Username
            Text(
          widget.user.name.toString(),
          style: GoogleFonts.caveat(
              color: Colors.white,
              fontSize: 22.sp,
              letterSpacing: 0.8.w,
              fontWeight: FontWeight.w500,
              shadows: [
                const Shadow(
                  color: Colors.black54,
                  blurRadius: 1,
                  offset: Offset(1, 1),
                ),
                const Shadow(
                  color: Colors.black54,
                  blurRadius: 1,
                  offset: Offset(-1, -1),
                )
              ]),
        ),
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
      ),
      body: Column(
        children: [
          ///Profile Image
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 5,
              shadowColor: Colors.black54,
              // ),
              child: SizedBox(
                height: 60.h,
                child: Stack(
                  fit: StackFit.passthrough,
                  children:[

                    ///User Image
                    ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: widget.user.image.toString(),
                      fit: BoxFit.fitHeight,
                    ),
                  ),

                    ///User Email
                    Positioned(
                      height: 9.5.h,
                      width: 100.w,
                      bottom: 0,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Email", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18.sp),),
                              Text(
                                widget.user.email.toString(),softWrap: true,overflow: TextOverflow.ellipsis,maxLines: 2,
                                style:
                                GoogleFonts.roboto(fontSize: 18.sp, color: Colors.black,),
                              ),
                            ],
                          )),
                    ),
                  ]
                ),
              ),
            ),
          ),

          ///About
          Card(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: widget.paletterGenerator.dominantColor?.color ?? Colors.blue,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                  "About",
                  style: GoogleFonts.robotoSerif(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Text(
                  widget.user.about.toString(),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.k2d(
                    fontSize: 19.sp,
                  ),
                )
              ],),
            ),
          )
        ],
      ),
    );
  }
}

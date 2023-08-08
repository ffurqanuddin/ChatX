import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../resources/assets.dart';

class ProfileImageIcon extends StatelessWidget {
  const ProfileImageIcon({
    super.key,
    required myFirestoreData,
  }) : _myFirestoreData = myFirestoreData;

  final _myFirestoreData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 0.4.h,
      ),


      ///Profile Image Icon
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _myFirestoreData,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                margin: EdgeInsets.zero,
                shape: CircleBorder(),
                child: Icon(Icons.person, color: Colors.black,),
              );
            } else {
              final myProfilePic = snapshot.data?.data();
              return Card(
                margin: EdgeInsets.zero,
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                borderOnForeground: true,
                elevation: 2,
                shape: const CircleBorder(),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.h),
                  child: CachedNetworkImage(
                    imageUrl: myProfilePic?["image"]??Assets.firebaseDpImage,
                    fit: BoxFit.cover,
                    width: 5.h, // Adjust the dimensions as needed
                    height: 5.h,
                  ),
                ),
              );
            }
          } else{
           return const ClipOval(
              child: Text(""),
            );
          }
        },
      ),
    );
  }
}
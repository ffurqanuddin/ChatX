// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx/api/api.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/pages/home/home_page.dart';
import 'package:chatx/widgets/custom_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../helper/dialogs.dart';
import '../widgets/custom_profile_image_cliprrect.dart';

class ProfilePage extends StatefulWidget {
   ProfilePage({super.key, getSelfInfo,});



  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>  {

  ///Firestore
  final _myFirestoreDoc =

      ///Firestore
      APIs.firestore.collection("users").doc(APIs.cuser.email);

  ///Image from Image Picker
  String? _profilePickedImage;





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myFirestoreDoc;


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        ///AppBar Background Color
        backgroundColor: Colors.transparent,

        ///Back Button
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Helper.navigateReplaceToScreen(const HomePage(), context);
            }),

        actions: [
        IconButton(onPressed: (){
          _showModalBottomSheet();
        }, icon: Icon(MdiIcons.pencilBox, size: 8.w,))
          
        ],
        
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: _myFirestoreDoc.snapshots(),
          builder: (context, snapshot) {
            ///Initial value of Username TextField
            String userName =
                snapshot.data?.data()?["name"] ?? "please update your name";

            ///initial Value of About TextField
            String about =
                snapshot.data?.data()?["about"] ?? "Hey, I'm using ChatX";

            try {
              ///Firestore Data
              final data = snapshot.data!.data();

              switch (snapshot.connectionState) {
                ///ConnectionState Waiting
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const CircularProgressIndicator(
                    color: Colors.black,
                  );

                ///ConnectionState Done
                case ConnectionState.active:
                case ConnectionState.done:
                  print(data!);

                  return Column(
                    children: [
                      ///Profile Image
                      SizedBox(

                        height: 55.h,
                        width: double.infinity,
                        ///if (_profileImage = Image Picked fromGallery)? then show it otherwise load image from Firestore Database
                        child: _profilePickedImage != null
                            ? ProfileImageClipRRect(
                                child: Image.file(
                                File(_profilePickedImage!),
                                fit: BoxFit.cover,
                              ))
                            : (((data["image"]) == null)
                                ? ProfileImageClipRRect(
                                    child: Image.asset(
                                      "assets/chat_user.png",
                                      fit: BoxFit.cover,
                                    ),
                                  )

                                ///if image from firestore is null then use asset image
                                : ProfileImageClipRRect(
                                    child: CachedNetworkImage(
                                      imageUrl: data["image"],
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                      ),

                      SizedBox(
                        height: 2.h,
                      ),

                      ///Current UserEmail
                      Container(
                        padding: EdgeInsets.all(2.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.purple,
                              Colors.pink,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Text(
                          APIs.cuser.email.toString(),
                          style: GoogleFonts.abel(
                            color: Colors.white,
                            fontSize: 16.sp,
                            shadows: [
                              const Shadow(
                                color: Colors.black,
                                offset: Offset(0, 0),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),


                      SizedBox(
                        height: 3.h,
                      ),

                      ///Username
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0.1.h, horizontal: 3.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.7.h, horizontal: 6.w),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextFormField(

                              ///Close Keyboard after taping outside of TextField
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus!.unfocus(),
                              initialValue: data["name"],
                              onChanged: (value) {
                                userName = value;
                              },
                              style: const TextStyle(color: Colors.white),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Please fill name section",
                                hintStyle: TextStyle(color: Colors.white54),
                              )),
                        ),
                      ),

                      SizedBox(
                        height: 2.5.h,
                      ),

                      ///About
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0.1.h, horizontal: 3.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.7.h, horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextFormField(

                              ///Close Keyboard after taping outside of TextField
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus!.unfocus(),
                              maxLines: 3,
                              minLines: 1,
                              initialValue: data["about"],
                              style: const TextStyle(color: Colors.white),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Please fill about section";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                about = value;
                              },
                              decoration: const InputDecoration(
                                hintText: "Tell me about your self",
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              )),
                        ),
                      ),

                      SizedBox(
                        height: 2.5.h,
                      ),

                      ///Update Button
                      CustomAuthButton(
                        btnColor: Colors.amber,
                        child: Text(
                          "Update",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              letterSpacing: 0.3.w,
                              fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          ///update user data on firestore
                          _updateUserProfile(userName: userName, about: about);
                        },
                      )
                    ],
                  );
              }
            } catch (error) {
              print('Error: $error');
              return const Text('An error occurred.');
            }
          },
        ),
      ),
    );
  }

  ////////////////////////////////////////////////
  /////////////***METHODS***/////////////////////
  ///////////////////////////////////////////////

  ///Update User Profile name and about data
  Future _updateUserProfile({userName, about}) async {
    ///Loading Circular Progress Indicator
    Dialogs.showCircularProgressBar(context);

    ///Update Data
    await _myFirestoreDoc.update({
      "name": userName,
      "about": about,
    }).then((value) {
      ///Close Circular Dialog Box
      setState(() {
        Navigator.pop(context);
      });

      ///Now Navigate to HomeScreen
      Helper.navigateReplaceToScreen(const HomePage(), context);
    });
  }

  ///Show Modal Bottom Sheet, To pick Profile image from Gallery or Camera
  Future _showModalBottomSheet() => showModalBottomSheet(
        context: context,
        builder: (context) => ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 1.h,
            ),

            ///Pick Image Text
            Text(
              "Pick Image",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  fontSize: 20.sp, fontWeight: FontWeight.w500),
            ),

            SizedBox(
              height: 1.h,
            ),

            ///Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///Pick Image from Gallery Icon
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        ///PickImageMethod
                        _pickImageFromPhone(ImageSource: ImageSource.gallery);
                      },
                      icon: Icon(MdiIcons.viewGallery, size: 28.sp),
                    ),
                    const Text("Gallery")
                  ],
                ),

                ///Pick Image from Camera Icon
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        ///PickImageMethod
                        _pickImageFromPhone(ImageSource: ImageSource.camera);
                      },
                      icon: Icon(MdiIcons.camera, size: 28.sp),
                    ),
                    const Text("Camera")
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 3.h,
            ),
          ],
        ),
      );

  ///Pick Image Method
  _pickImageFromPhone({required ImageSource}) async {
    final ImagePicker picker = ImagePicker();

    /// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource);
    if (image != null) {
      setState(() {
        ///Profile Image
        _profilePickedImage = image.path;
      });



      ///Update and Store Profile Image to firebase Storage
      APIs.updateUserProfileImage(File(_profilePickedImage!));

      ///For Hiding Bottom Modal Sheet
      Navigator.pop(context);

      ///Show Dialogs after update image
      Dialogs.showSnackbar(
          msgColor: Colors.green,
          msg: "Profile Image is successfully updated",
          color: Colors.white);
    }
  }
}

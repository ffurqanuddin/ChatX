import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/helper/my_date_util.dart';
import 'package:chatx/models/chat_user.dart';
import 'package:chatx/models/message.dart';
import 'package:chatx/pages/home/home_page.dart';
import 'package:chatx/pages/home/view_profile_page.dart';
import 'package:chatx/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../api/api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ///for storing all messages
  List<Message> _list = <Message>[];

  ///for handling message text changes
  final _textController = TextEditingController();

  ///This is alternative method instead of using setState
  final ValueNotifier<bool> _cameraIconNotifier = ValueNotifier<bool>(true);

  ///For storing value of showing or hiding emoji
  bool _showEmoji = false;


  ///Gradient Color Generator According to Image for view Profile Page
  late PaletteGenerator _paletteGenerator;

  Future<PaletteGenerator> generatePalette(String imageUrl) async {
    final PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl) // Use your user's image URL here
    );
    return paletteGenerator;
  }

  Future<void> _loadPalette() async {
    final palette = await generatePalette(widget.user.image.toString());
    setState(() {
      _paletteGenerator = palette;
    });
  }

  @override
  void initState() {
    super.initState();
    _cameraIconNotifier.value = true;

    ///Initialize Gradient Color
    _loadPalette();// Set initial value
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cameraIconNotifier.dispose();
    _textController.dispose();
    _loadPalette();
    dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
          } else {
            _onWillPop();
          }

          return false;
        },
        child: Scaffold(
          ///AppBar
          appBar: _appBar(context),

          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  // stream: APIs.firestore.collection("chats/${getConversationID(APIs.user.uid)}/messages/").snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (snapshot.hasData) {
                          final data = snapshot.data!.docs;
                          print("Data: Snapshot.data!.docs\n${data.length}");
                          try {
                            _list = data
                                .map((e) => Message.fromJson(e.data()))
                                .toList();
                          } catch (e) {
                            print(
                                "Error message of chat_screen _ add data in _list \n $e");
                            return Center(
                              child: Text(
                                "Something went wrong!",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                ),
                              ),
                            );
                          }

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              itemCount: _list.length,
                              physics: const BouncingScrollPhysics(),
                              reverse: true, // Reverse the order of the list

                              itemBuilder: (context, index) {
                                // Reverse the order of the messages
                                final reversedIndex = _list.length - 1 - index;
                                return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: MessageCard(
                                      message: _list[reversedIndex]),
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                "Say Hii 👋",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                ),
                              ),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Snapshot Error: ${snapshot.error}",
                              style: TextStyle(
                                fontSize: 18.sp,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                    }
                  },
                ),
              ),
              //////////////////////////////////////////////
              ///Bottom Send Text Fields & Buttons Section///
              Padding(
                padding: EdgeInsets.only(
                    right: 2.w, left: 2.w, bottom: 1.h, top: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ///Section 1////
                    Expanded(
                      child: Card(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ///Emoji Icon
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  _showEmoji = !_showEmoji;
                                });
                              },
                              icon: Icon(
                                MdiIcons.stickerEmoji,
                              ),
                            ),

                            ///TextField
                            Expanded(
                              child: ValueListenableBuilder<bool>(
                                  valueListenable: _cameraIconNotifier,
                                  builder: (context, isTextFieldEmpty, child) {
                                    return TextField(
                                      keyboardType: TextInputType.multiline,
                                      onTap: () {
                                        if (_showEmoji)
                                          setState(() {
                                            _showEmoji = !_showEmoji;
                                          });
                                      },
                                      controller: _textController,
                                      selectionControls:
                                          CupertinoDesktopTextSelectionControls(),
                                      onChanged: (value) {
                                        // ///if TextField value is empty make camera icon visible
                                        _cameraIconNotifier.value =
                                            value.isEmpty;
                                      },
                                      maxLines: 6,
                                      minLines: 1,
                                      scrollPhysics:
                                          const ClampingScrollPhysics(),
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Type something..."),
                                    );
                                  }),
                            ),

                            ///pick image from gallery button
                            IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();

                                // Picking multiple images
                                final List<XFile> images = await picker
                                //Image Quality
                                    .pickMultiImage(imageQuality: 60);

                                // uploading & sending image one by one
                                for (var i in images) {
                                  print('Image Path: ${i.path}');
                                  await APIs.sendChatImage(
                                      widget.user, File(i.path));
                                  print("Image is upload from gallery!");
                                }
                              },
                              icon: const Icon(
                                CupertinoIcons.photo,
                              ),
                            ),

                            ///Camera Icon
                            ValueListenableBuilder(
                              valueListenable: _cameraIconNotifier,
                              builder: (context, value, child) {
                                return Visibility(
                                  visible: value,

                                  ///take image from camera button
                                  child: IconButton(
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();

                                      // Pick an image
                                      final XFile? image =
                                          await picker.pickImage(
                                              source: ImageSource.camera,

                                              ///Image Quality
                                              imageQuality: 60);
                                      if (image != null) {
                                        print('Image Path: ${image.path}');

                                        await APIs.sendChatImage(
                                            widget.user, File(image.path));
                                        print("Image from camera is uploaded");
                                      }
                                    },
                                    icon: Icon(
                                      MdiIcons.camera,
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(
                              width: 1.w,
                            ),
                          ],
                        ),
                      ),
                    ),

                    ///Section 2////
                    ///Send Message Button
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h, left: 0.5.w),
                      child: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: IconButton(
                            onPressed: () {
                              if (_textController.text.isNotEmpty) {
                                APIs.sendMessage(widget.user,
                                    _textController.text, Type.text);

                                if (kDebugMode) {
                                  print("Message : ${_textController.text}");
                                }
                                _textController.clear();
                              }
                            },
                            icon: Icon(
                              MdiIcons.send,
                              color: Colors.white,
                            ),
                          )),
                    )
                  ],
                ),
              ),

              ///show emojis on keyboard emoji button click & vice versa
              if (_showEmoji)
                SizedBox(
                  height: 35.h,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor: ThemeData.dark().primaryColor,
                      columns: 7,
                      emojiSizeMax: 32 * 1.0,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  ///***Custom Widgets***//////////////
//////////////////////////////////////////////////

  PreferredSize _appBar(BuildContext context) {
    return PreferredSize(
        preferredSize: Size(double.infinity, 7.5.h),
        child: GestureDetector(
          ///View Profile Page of particular User
          onTap: (){
            Helper.naviagteToScreen(ViewProfileImage(user: widget.user,loadPalette: _loadPalette,paletterGenerator: _paletteGenerator), context);
          },
          child: StreamBuilder(
              stream: APIs.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];


                return Card(
                  margin: EdgeInsets.zero,
                  child: Container(
                    ///AppBar Padding
                    padding: EdgeInsets.only(
                      top: 5.h,
                    ),

                    ///AppBar Background Color
                    color: Colors.grey[800],
                    // color: Colors.black,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                                (route) => true);
                          },
                          icon: const Icon(
                            CupertinoIcons.back,
                          ),
                        ),

                        SizedBox(
                          width: 1.w,
                        ),

                        ///Profile Image
                        Card(
                          color: Colors.transparent,
                          borderOnForeground: true,
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: list.isNotEmpty
                                  ? list[0].image.toString()
                                  : widget.user.image.toString(),
                              fit: BoxFit.cover,
                              width: 5.5.h, // Adjust the dimensions as needed
                              height: 5.5.h,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 2.w,
                        ),

                        ///Name & Last Seen
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ///Username & is user verified show blue tick
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ///Profile name
                                Text(
                                  list.isNotEmpty
                                      ? list[0].name.toString()
                                      : widget.user.name.toString(),
                                  style: TextStyle(
                                    fontSize: 18.sp, fontWeight: FontWeight.w500,

                                    ///Temp Change
                                    //   color: Colors.white
                                  ),
                                ),

                                ///Blue Verification Tick
                                if (widget.user.verified == true)
                                  Icon(
                                    Icons.verified,
                                    size: 18.sp,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),
                            Text(
                              list.isNotEmpty
                                  ? (list[0].isOnline == true)
                                      ? "Online"
                                      : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive.toString())
                                  : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive.toString()),
                              style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.w400,
overflow: TextOverflow.ellipsis

                                ///Temp Change
                                // color: Colors.white70
                              ),
                            ),
                          ],
                        ),

                        ///Space between *** and call icon
                        const Spacer(),

                        ///Video Call
                        InkWell(
                          onTap: () {
                            _showVideoCallCupertinoDialog(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Icon(MdiIcons.video),
                          ),
                        ),

                        ///Audio Call
                        InkWell(
                          onTap: () {
                            _showAudioCallCupertinoDialog(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Icon(MdiIcons.phone),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ));
  }

//////////////////////////////////////////////////
  ///***Methods***//////////////////////
//////////////////////////////////////////////////

  ///OnWillPop button Click trigger this Method
  _onWillPop() {
    // Navigates to the HomePage and removes all previous routes from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
      (route) => false, // Use false to remove all routes from the stack
    );
  }
}

///Video Call & AUdio Call "Coming Soon"
Future<dynamic> _showVideoCallCupertinoDialog(BuildContext context) {
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoDialogAction(
        child: Container(
            height: 30.h,
            width: 80.w,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    "Video Call feature are coming soon",
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Center(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            "OK",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ))),
  );
}

Future<dynamic> _showAudioCallCupertinoDialog(BuildContext context) {
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoDialogAction(
        child: Container(
            height: 30.h,
            width: 80.w,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    "Audio Call feature are coming soon",
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Center(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            "OK",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ))),
  );
}

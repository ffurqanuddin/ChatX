import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/helper/my_date_util.dart';
import 'package:chatx/models/chat_user.dart';
import 'package:chatx/models/message.dart';
import 'package:chatx/pages/chat_screen.dart';
import 'package:chatx/widgets/view_profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../api/api.dart';

// ignore: must_be_immutable
class ChatUserCard extends StatefulWidget {
  ChatUserCard({super.key, required this.user});

  ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  ///lat message info (if null --> no messages
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Card(
        elevation: 0.8,
        shadowColor: Colors.white,
        child: InkWell(
          ///On Tap
          onTap: () {
            ///Navigate to ChatScreen
            Helper.navigateReplaceToScreen(
                ChatScreen(user: widget.user), context);
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _message = list[0];

                return ListTile(

                    ///User Image
                    leading: GestureDetector(
                      onTap: (){
                        ///Show view profile dialog
                        showDialog(context: context, builder: (context) => ViewProfileDialog(user: widget.user),);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          height: 6.h,
                          width: 6.h,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image.toString(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                        ),
                      ),
                    ),

                    ///Title
                    title: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        widget.user.name.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                      ),

                      ///Blue Verification Tick
                      if (widget.user.verified == true)
                        Icon(
                          Icons.verified,
                          size: 18.sp,
                          color: Colors.blue,
                        ),
                    ]),

                    ///last message
                    subtitle: Text(
                      _message != null
                          ? _message!.msg
                          : widget.user.about.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),

                    ///last message time
                    trailing: _message == null
                        ? null  //show nothing when no messages is sent
                        : _message!.read.isEmpty && _message?.fromId != APIs.cuser.uid
                            ? CircleAvatar(
                                backgroundColor: Colors.blue, maxRadius: 0.7.h)
                            : Text(
                                MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                                style: const TextStyle(color: Colors.white),
                              ));
              }),
        ),
      ),
    );
  }
}

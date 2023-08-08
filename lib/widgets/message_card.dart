import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/helper/my_date_util.dart';
import 'package:chatx/pages/home/image_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Import the google_fonts package
import '../api/api.dart';
import '../helper/dialogs.dart';
import '../models/message.dart';


class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    // Get the app theme from the context
    ThemeData appTheme = Theme.of(context);

    return InkWell(
      onLongPress: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => _MessageCardLongPress(
            message: widget.message,
            msg: widget.message.msg,
            id: widget.message.fromId,
            messageType: widget.message.type,
          ),
        );
      },
      child: APIs.cuser.uid == widget.message.fromId
          ? _myMessage(appTheme)
          : _otherMessage(appTheme),
    );
  }

  /// Sender or another user message
  Widget _otherMessage(ThemeData theme) {
    ///update last read message if sendeer and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      print("message read updated");
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 2,
        margin:
            EdgeInsets.only(top: 0.8.h, bottom: 0.8.h, left: 3.w, right: 20.w),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        )),
        child: Container(
          padding: EdgeInsets.all(15.sp),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepOrange],
              // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///message content
              widget.message.type == Type.text
                  ? Text(
                      widget.message.msg,
                      style: GoogleFonts.poppins(fontSize: 15.sp),
                    )
                  :

                  ///Show Image
                  GestureDetector(
                      onTap: () {
                        Helper.naviagteToScreen(
                            ImagePreview(imageUrl: widget.message.msg),
                            context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.h),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          errorWidget: (context, url, error) => Icon(
                            Icons.image,
                            size: 70.sp,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ///read time
                  Text(
                    MyDateUtil.getFormattedTime(
                        context: context, time: widget.message.read),
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Our or user message
  Widget _myMessage(ThemeData theme) {
    bool isDarkTheme = theme.brightness == Brightness.dark;
    Color gradientStartColor;
    Color gradientEndColor;

    if (isDarkTheme) {
      gradientStartColor = Colors.deepPurple.shade800;
      gradientEndColor = Colors.blue.shade800;
    } else {
      gradientStartColor = Colors.deepPurple;
      gradientEndColor = Colors.blue;
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Card(
        margin:
            EdgeInsets.only(top: 0.8.h, bottom: 0.8.h, left: 20.w, right: 3.w),
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            ///Chat Card background Color
            gradient: LinearGradient(
              colors: [gradientStartColor, gradientEndColor],
              // Different gradient colors for sender's message (Purple to Blue)
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ///message content
              (widget.message.type == Type.text)
                  ? Text(
                      widget.message.msg,
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                    )
                  :

                  ///Show Image
                  GestureDetector(
                      onTap: () {
                        Helper.naviagteToScreen(
                            ImagePreview(imageUrl: widget.message.msg),
                            context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.h),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          errorWidget: (context, url, error) => Icon(
                            Icons.image,
                            size: 70.sp,
                          ),
                        ),
                      ),
                    ),

              SizedBox(height: 0.9.h),

              ///sent
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    MyDateUtil.getFormattedTime(
                        context: context, time: widget.message.sent),
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: Colors.white54),
                  ),

                  ///double tick icon for message read
                  _readMessageIcon(widget.message.read, isDarkTheme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Read Messages Icon
  Widget _readMessageIcon(String isRead, bool isDarkTheme) {
    IconData iconData = Icons.done;
    Color iconColor = isDarkTheme ? Colors.white : Colors.black;

    return isRead.isNotEmpty
        ? Icon(
            Icons.done_all,
            size: 18.sp,
            color: iconColor,
          )
        : Icon(
            iconData,
            size: 18.sp,
            color: iconColor,
          );
  }
}
class _MessageCardLongPress extends StatelessWidget {
  const _MessageCardLongPress({
    required this.msg,
    this.id,
    required this.messageType,
    required this.message,
  });


  final message;
  ///(If messageTpye is text) then msg will be text else it will be direct url of image
  final dynamic msg;
  final dynamic id;
  final Type messageType;

   ///Save Image from Url
  _saveNetworkImage() async {
    var response = await Dio().get(
       msg,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 80,
        name: id.toString());
    print(result);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: APIs.cuser.uid == id?15.h:10.h,
      child: Material(
        child: Column(
          children: [
            ///*** Copy Text or Save Image ***///
            ListTile(
              onTap: () async {
                if (messageType == Type.text) {
                  await Clipboard.setData(ClipboardData(text: msg));
                } else if (messageType == Type.image) {
                  // Save Image to the Gallery
               _saveNetworkImage();
               Dialogs.showSnackbar(msg: "Image is succesfully saved", color: Colors.green,msgColor: Colors.white);
                }

                Navigator.pop(context);
              },
              title: messageType == Type.text
                  ? const Text("Copy Text")
                  : const Text("Save Image"),
              trailing: Icon(
                messageType == Type.text
                    ? MdiIcons.contentCopy
                    : CupertinoIcons.photo,
              ),
            ),

            /// Delete Message
           if(APIs.cuser.uid == id) ListTile(
              onTap: () {
                APIs.deleteMessage(message);
                Navigator.pop(context);
              },
              title: const Text("Delete Message"),
              trailing: Icon(MdiIcons.delete),
            ),
          ],
        ),
      ),
    );
  }


}

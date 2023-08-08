import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/api.dart';
import '../../models/chat_user.dart';
import '../../widgets/chat_user_card.dart';

// ignore: must_be_immutable
class ChatsTab extends StatefulWidget {
  ChatsTab({super.key, required this.list});

  List list;

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: APIs.getAllUsers(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => SizedBox(
                  width: 200.0,
                  height: 100.0,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.grey.shade800,
                    child: SizedBox(
                      height: 10.h,
                      width: double.infinity,
                    ),
                  ),
                ),
              );

            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              try {
                widget.list =
                    data!.map((e) => ChatUser.fromJson(e.data())).toList();
              } catch (e) {
                print("widget.list error : \n$e");
                return const Center(
                  child: Text("No Connection Found!"),
                );
              }
          }

          if (widget.list.isNotEmpty) {
            return ListView.builder(
              padding: EdgeInsets.only(top: 0.8.h),
              ///TO Preserve Scroll Position
              key: const PageStorageKey<String>("Page"),
              itemCount:  widget.list.length,
              itemBuilder: (context, index) => ChatUserCard(
                user: widget.list[index],
              ),
            );
          } else {
            return const Center(
              child: Text("No Connection found!"),
            );
          }
        });
  }
}
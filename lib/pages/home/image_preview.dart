import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ImagePreview extends StatelessWidget {
   ImagePreview({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: (){
        Navigator.pop(context);
      }),),
      extendBodyBehindAppBar: true,
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          errorWidget: (context, url, error) => const Icon(Icons.image),
        ),
      ),
    );
  }
}

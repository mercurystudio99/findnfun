import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_app/plugins/stories/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  // Variables
  final String imageUrl;
  final IconData? pIconData;

  const CachedImage(this.imageUrl, {Key? key, this.pIconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: imageUrl,
      placeholder: (context, url) =>
        PlaceHolder(Icon(pIconData ?? Icons.favorite_border, size: 150)),
      errorWidget: (context, url, error) => 
              const Center(child: Icon(Icons.error, size: 70)),
      );
  }
}

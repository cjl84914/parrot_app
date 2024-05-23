import 'dart:io';

import 'package:flutter/material.dart';
import 'package:parrot/providers/user.dart';
import 'package:parrot/ui/mobile/widgets/future_tile_image.dart';
import 'package:provider/provider.dart';

class ImageSelectorTile extends StatelessWidget {
  final Future<File> image;

  const ImageSelectorTile({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final user = context.read<User>();
        user.profile = image;
      },
      child: GridTile(
        child: FutureTileImage(
          image: image,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
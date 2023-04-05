import 'dart:io';

import 'package:flutter/material.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({super.key, required this.link});
  final String link;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {

  @override
  Widget build(BuildContext context) {
    return Image.network(widget.link);
  }
}
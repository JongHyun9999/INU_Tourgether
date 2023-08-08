import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';

class UserPostDetailScreen extends StatefulWidget {
  UserPostDetailScreen({
    super.key,
    required this.user_id,
    required this.content,
    required this.latitude,
    required this.longitude,
    required this.liked,
    required this.posted_time,
  });
  final String user_id;
  final String content;
  final double latitude;
  final double longitude;
  final int liked;
  final String posted_time;

  @override
  State<UserPostDetailScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UserPostDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          iconTheme: IconThemeData(
            color: ColorPalette.onPrimaryContainer,
          ),
          backgroundColor: ColorPalette.primaryContainer,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${widget.user_id}"),
            Text("${widget.content}"),
            Text("${widget.latitude}"),
            Text("${widget.longitude}"),
            Text("${widget.liked}"),
            Text("${widget.posted_time}"),
          ],
        ),
      ),
    );
  }
}

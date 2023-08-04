import 'package:flutter/material.dart';

class UserPostDetailScreen extends StatefulWidget {
  UserPostDetailScreen({
    super.key,
    required this.author,
    required this.content,
    required this.latitude,
    required this.longitude,
    required this.liked,
    required this.posted_time,
  });
  final String author;
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
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${widget.author}"),
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

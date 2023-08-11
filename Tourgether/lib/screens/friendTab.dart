import 'package:flutter/material.dart';

class friendTab extends StatefulWidget {
  const friendTab({super.key});

  @override
  State<friendTab> createState() => _friendTabState();
}

class _friendTabState extends State<friendTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("FriendsTab"),
      ),
    );
  }
}

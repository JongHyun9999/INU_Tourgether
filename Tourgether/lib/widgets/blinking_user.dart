import 'package:flutter/material.dart';

class BlinkingIcon extends StatefulWidget {
  final IconData iconData;
  final Duration blinkDuration;

  BlinkingIcon(
      {required this.iconData,
      this.blinkDuration = const Duration(seconds: 2)});

  @override
  _BlinkingIconState createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<BlinkingIcon> {
  bool _isBlinking = true;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(widget.blinkDuration, () {
      if (mounted) {
        setState(() {
          _isBlinking = !_isBlinking;
        });
        _startBlinking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: _isBlinking ? 0.5 : 1.0),
      duration: widget.blinkDuration,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Icon(
            widget.iconData,
            size: 32.0, // Adjust the size as needed
          ),
        );
      },
    );
  }
}

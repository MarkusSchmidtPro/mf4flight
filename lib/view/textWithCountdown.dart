import 'dart:async';

import 'package:flutter/material.dart';

// https://www.appsloveworld.com/flutter/100/37/update-snackbar-content-in-flutter

class TextWithCountdown extends StatefulWidget {
  final String text;
  final int countValue;
  final VoidCallback? onCountDown;

  const TextWithCountdown({
    Key? key,
    required this.text,
    required this.countValue,
    this.onCountDown,
  }) : super(key: key);

  @override
  _TextWithCountdownState createState() => _TextWithCountdownState();
}

class _TextWithCountdownState extends State<TextWithCountdown> {
  late int count = widget.countValue;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), _timerHandle);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String s = widget.text.replaceFirst("\[count\]", count.toString());
    return Container(child: Text(s));
  }

  void _timerHandle(Timer timer) {
    setState(() {
      count -= 1;
    });
    if (count <= 0) {
      timer.cancel();
      widget.onCountDown?.call();
    }
  }
}

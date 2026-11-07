import 'package:flutter/material.dart';

import 'command_buttons.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.actions, super.key});

  final List<CommandButton> actions;

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions,
    ),
  );
}

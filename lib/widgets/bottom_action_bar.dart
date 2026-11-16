import 'package:flutter/material.dart';

import 'command_buttons.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.actions, super.key});

  final List<CommandButton> actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(top: BorderSide(color: cs.surfaceDim, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: actions,
          ),
        ),
      ),
    );
  }
}


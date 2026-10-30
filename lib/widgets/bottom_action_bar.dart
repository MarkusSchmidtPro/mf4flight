import 'package:flutter/material.dart';

import 'command_buttons.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.actions,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
  });

  final List<CommandButton> actions;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.where((c) => c.visible).toList();
    if (visibleActions.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisAlignment: mainAxisAlignment, children: visibleActions);
  }
}
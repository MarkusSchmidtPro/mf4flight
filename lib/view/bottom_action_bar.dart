import 'package:flutter/material.dart';

import '../view_model/view_command.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.actions,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
  });

  final List<CommandIcon> actions;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.where((c) => c.visible).toList();
    if (visibleActions.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisAlignment: mainAxisAlignment, children: visibleActions);
  }
}

class CommandIcon extends StatelessWidget {
  CommandIcon({
    super.key,
    required this._command,
    required this._icon,
    this._label,
    this._highlighted = false,
  });

  factory CommandIcon.action({
    required Future<void> Function() action,
    required IconData icon,
    String? label,
    bool highlighted = false,
  }) => CommandIcon(
    icon: icon,
    command: ViewCommand(action: action),
    highlighted: highlighted,
    label: label,
  );

  final ViewCommand _command;
  final bool _highlighted;
  final IconData _icon;
  final String? _label;

  bool get visible => _command.visible;

  bool get enabled => _command.enabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _command.enabled ? _command.action : null,
      style: TextButton.styleFrom(
        foregroundColor: _highlighted ? Theme.of(context).colorScheme.primary : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(_icon), if (_label != null) Text(_label)],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../view_model/command.dart';

// see 'buttons.md'

/// A command widget - the visual representation of a [Command].
///
class CommandButton extends StatelessWidget {
  const CommandButton({required this.command, required this._child, super.key});

  final Command command;
  final Widget _child;

  /// A [Command] reprsented by an [icon] with an optional [label].
  CommandButton.iconLabel({
    required IconData icon,
    required Command command,
    String? label,
    Color? iconColor,
  }) : command = command,
       _child = IconLabelButton(
         onPressed: command.action,
         icon: icon,
         label: label,
         iconColor: iconColor,
       );

  static Color highlightColor(context) => Theme.of(context).colorScheme.secondaryContainer;

  CommandButton.nav({required IconData icon, required String label, required Command command})
    : command = command,
      _child = FilledButton.tonalIcon(
        onPressed: command.state == VisualState.enabled ? command.action : null,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // fill the width it's given
          shape: const StadiumBorder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (command.state == VisualState.invisible) return const SizedBox.shrink();
    return Opacity(opacity: command.state == VisualState.enabled ? 1.0 : 0.38, child: _child);
  }
}

class IconLabelButton extends StatelessWidget {
  const IconLabelButton({
    super.key,
    required this._onPressed,
    required this._icon,
    required this._label,
    this._iconColor,
  });

  final Function()? _onPressed;
  final IconData _icon;
  final String? _label;

  final Color? _iconColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(4),
    child: TextButton(
      onPressed: _onPressed,
      style: TextButton.styleFrom(foregroundColor: _iconColor, iconColor: _iconColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(_icon, size: 24), if (_label != null) Text(_label)],
      ),
    ),
  );
}

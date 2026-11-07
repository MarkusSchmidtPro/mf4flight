import 'package:flutter/material.dart';

import '../view_model/command.dart';

/*
	FilledButton.tonalIcon	TextButton
  Background	      Filled (secondaryContainer)	    None (transparent)
  Text/icon color	  onSecondaryContainer	          primary
  Emphasis	        Medium: clearly looks like a button
                                                    Low: looks like a link until pressed
  Press feedback	  Ripple over the fill	          Ripple/highlight on empty background
  Typical use	      Nav tiles, secondary actions	  Toolbars, dialogs, inline actions
 */

/// IconButton behavior.
/*class CommandIconButton extends StatelessWidget {
  const CommandIconButton({
    required this._command,
    required this._icon,
    this._color,
    this._size,
    this._tooltip,
    super.key,
  });

  CommandIconButton.action({
    required CommandAction action,
    required this._icon,
    this._color,
    this._size,
    this._tooltip,
    super.key,
  }) : _command = Command(action: action);

  final Command _command;
  final IconData _icon;
  final Color? _color;
  final double? _size;
  final String? _tooltip;

  @override
  Widget build(BuildContext context) {
    if (!_command.isVisible) return const SizedBox.shrink();

    return Opacity(
      opacity: _command.enabled ? 1.0 : 0.38,
      child:  IconButton(
        icon: Icon(_icon, color: _color, size: _size),
        tooltip: _tooltip,
        onPressed: _command.enabled ? _command.action : null,
      ),
    );
  }
}
*/

/// The visual representation of a [Command].
///
class CommandButton extends StatelessWidget {
  const CommandButton({required this._command, required this._child, super.key});

  final Command _command;
  final Widget _child;

  /// A visble [IconLabelButton]
  CommandButton.iconLabel({
    required IconData icon,
    required Command command,
    String? label,
    Color? iconColor,
  }) : _command = command,
       _child = IconLabelButton(
         onPressed: command.action,
         icon: icon,
         label: label,
         iconColor: iconColor,
       );

  static Color highlightColor(context) => Theme.of(context).colorScheme.primary;

  CommandButton.nav({required IconData icon, required String label, required Command command})
    : _command = command,
      _child = FilledButton.tonalIcon(
        onPressed: command.state == VisualState.enabled ? command.action : null,
        icon: Icon(icon), // size: 16
        label: Text(label ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(32), // fill the width it's given
          shape: const StadiumBorder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_command.state == VisualState.invisible) return const SizedBox.shrink();
    return Opacity(opacity: _command.state == VisualState.enabled ? 1.0 : 0.38, child: _child);
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
      style: TextButton.styleFrom(
        foregroundColor: _iconColor,
        iconColor: _iconColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(_icon), if (_label != null) Text(_label)],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'command.dart';

/*
	FilledButton.tonalIcon	TextButton
  Background	      Filled (secondaryContainer)	    None (transparent)
  Text/icon color	  onSecondaryContainer	          primary
  Emphasis	        Medium: clearly looks like a button
                                                    Low: looks like a link until pressed
  Press feedback	  Ripple over the fill	          Ripple/highlight on empty background
  Typical use	      Nav tiles, secondary actions	  Toolbars, dialogs, inline actions
 */

/// Composite / TextButton + Column with Label)
class CommandButton extends StatelessWidget {
  CommandButton({
    required this._command,
    required this._icon,
    this._label,
    this._highlighted = false,
    super.key,
  });

  CommandButton.action({
    required CommandAction action,
    required this._icon,
    this._label,
    this._highlighted = false,
  }) : _command = Command(action: action);

  final Command _command;
  final bool _highlighted;
  final IconData _icon;
  final String? _label;

  bool get visible => _command.visible;

  bool get enabled => _command.enabled;

  @override
  Widget build(BuildContext context) {
    // 16 : Overflow on HelpIcon!
    return Padding( padding: EdgeInsets.all(4), child:TextButton(
      onPressed: _command.enabled ? _command.action : null,
      style: TextButton.styleFrom(
        foregroundColor: _highlighted ? Theme.of(context).colorScheme.primary : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(_icon), if (_label != null) Text(_label)],
      ),
    ));
  }
}

/// IconButton behavior.
class CommandIconButton extends StatelessWidget {
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
    if (!_command.visible) return const SizedBox.shrink();

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

class CommandNavButton extends StatelessWidget {
  const CommandNavButton({
    required this._icon,
    required this._label,
    required this._command,
    super.key,
  });

  CommandNavButton.action({
    required CommandAction action,
    required this._icon,
    required this._label,
    super.key,
  }) : _command = Command(action: action);

  final IconData _icon;
  final String _label;
  final Command _command;

  @override
  Widget build(BuildContext context) {
    if (!_command.visible) return const SizedBox.shrink();
    return Opacity(
      opacity: _command.enabled ? 1.0 : 0.38,
      child: FilledButton.tonalIcon(
        onPressed: _command.enabled ? _command.action : null,
        icon: Icon(_icon, size: 16),
        label: Text(_label),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(32), // fill the width it's given
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

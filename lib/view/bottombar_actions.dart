import 'package:flutter/material.dart';

import '../command/i_command.dart';

class BottomBarActions extends StatelessWidget {
  BottomBarActions({required List<BottomBarAction> actions}) : _actions = actions;

  final List<BottomBarAction> _actions;

  @override
  Widget build(BuildContext context) {
    ColorScheme _colors =
        Theme.of(context).buttonTheme.colorScheme ?? Theme.of(context).colorScheme;

    return BottomAppBar(
      child: Container(
        color: _colors.surface,
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              _actions.where((element) => element.style != BottomBarActionStyle.disabled).toList(),
        ),
      ),
    );
  }
}

enum BottomBarActionStyle { normal, highlighted, disabled }

class BottomBarAction extends StatelessWidget {
  final ICommand? _command;
  final IconData _icon;
  final String _label;
  late final BottomBarActionStyle _style;

  BottomBarAction(
      {required String label,
      required IconData icon,
      required ICommand? command,
      BottomBarActionStyle style = BottomBarActionStyle.normal})
      : _label = label,
        _icon = icon,
        _command = command {
    if (_command == null || !_command!.canExecute()) style = BottomBarActionStyle.disabled;
    _style = style;
  }

  BottomBarActionStyle get style => _style;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).buttonTheme.colorScheme ?? Theme.of(context).colorScheme;
    double dimFactor = 100;

    final List<Widget> content;
    switch (_style) {
      case BottomBarActionStyle.disabled:
        dimFactor = 50;
        content = [
          Opacity(
              opacity: dimFactor,
              child:Icon(_icon, color: colorScheme.onSurfaceVariant)),
          Text(_label, style: Theme.of(context).textTheme.button),
        ];
        break;

      case BottomBarActionStyle.normal:
        content = [
          Icon(_icon, color: colorScheme.onSurfaceVariant),
          Text(_label, style: Theme.of(context).textTheme.button),
        ];
        break;
/*
      case BottomBarActionStyle.disabled:
        [
          Icon(_icon, color: colorScheme.onSurfaceVariant),
          Text(_label, style: Theme.of(context).textTheme.button),
        ]
        Opacity(opacity: dimFactor, child: Icon(icon))
        content = [];
        break;
*/
      case BottomBarActionStyle.highlighted:
        content = [
    Opacity(
    opacity: 50,
    child:Icon(_icon, color: colorScheme.primary)),
          Text(_label, style: Theme.of(context).textTheme.button),
        ];
        break;
    }

    return content.length == 0
        ? SizedBox(width: 1, height: 1)
        : InkWell(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: content),
            onTap: () async {
              if (_command != null) await _command!.executeAsync(context);
            });
  }
}

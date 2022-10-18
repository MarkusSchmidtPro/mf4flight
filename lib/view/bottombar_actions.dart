import 'package:flutter/material.dart';

import '../command/i_command.dart';

class BottomBarActions extends StatelessWidget {
  BottomBarActions({required List<BottomBarAction> actions}) : _actions = actions;

  final List<BottomBarAction> _actions;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: _actions),
      ),
    );
  }
}

class BottomBarAction extends StatelessWidget {
  final ICommand _command;
  final Icon _icon;
  final String _label;

  BottomBarAction({required String label, required Icon icon, required ICommand command})
      : _label = label,
        _icon = icon,
        _command = command;

  @override
  Widget build(BuildContext context) {
    final List<Widget> content = !_command.canExecute() ? [Container()] : [_icon, Text(_label)];
    return InkWell(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: content),
        onTap: () async => await _command.executeAsync(context));
  }
}

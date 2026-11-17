import 'package:flutter/material.dart';

class BorderedContainer extends StatelessWidget {
  BorderedContainer({required this._child, this._color  });

  final Widget _child;
  final Color? _color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(border: Border.all(color: _color ?? cs.tertiaryContainer, width: 1)),
      child: _child,
    );
  }
}
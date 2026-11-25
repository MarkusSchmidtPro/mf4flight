import 'package:material_ui/material_ui.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.actions, super.key});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          border: Border(top: BorderSide(color: cs.surfaceDim, width: 1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: actions.map((action) => Flexible(child: action)).toList(),
        ),
      ),
    );
  }
}


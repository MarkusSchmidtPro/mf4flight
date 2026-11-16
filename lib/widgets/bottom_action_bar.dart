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

class BottomActionBar2 extends StatelessWidget {
  const BottomActionBar2({required this.actions, super.key});

  final List<CommandButton> actions;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(/*color: Exo.border*/)),
    ),
    child: SafeArea(
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            //for (final (n, t) in _tabs.indexed)
            for (final CommandButton a in actions)
              Expanded(
                child: InkWell(
                  onTap: a.command.action,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*                  SvgPicture.asset(
                    'assets/icons/${t.$2}.svg',
                    width: 22,
                    height: 22,
                    colorFilter:
                    ColorFilter.mode(n == tab ? Exo.navy : Exo.faint, BlendMode.srcIn),
                  ),*/
                      const SizedBox(height: 3),
                      Text(
                        "TEXT",
                        // style: Exo.body(11,
                        //     w: FontWeight.w600, color: n == tab ? Exo.navy : Exo.faint)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

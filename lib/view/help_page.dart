import 'dart:core';

import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:provider/provider.dart';

import '/locator.dart';
import '../widgets/command.dart';
import '../widgets/command_buttons.dart';
import 'help_page_vm.dart';

class HelpIcon extends StatelessWidget {
  const HelpIcon({required this._helpContext, super.key});

  final String _helpContext;

  @override
  Widget build(BuildContext context) {
    return CommandIconButton(
      command: Command(
        action: () async =>
        await navigator.push(MaterialPageRoute(builder: (_) => HelpPage.show(_helpContext))),
      ),size: 24,
      icon: Icons.help,
    );
  }
}

class HelpPage extends StatelessWidget {
  /* Private constructor to disallow ContactView instances.
     Instead ContactView.show( args) should be used to create
     a new ContactView with a bound ViewModel.
   */
  const HelpPage._();

  static StatelessWidget show(String helpKey, {Map<String, String>? values}) =>
      ChangeNotifierProvider<HelpViewModel>(
        create: (_) => HelpViewModel(helpKey, values: values),
        child: const HelpPage._(),
      );

  @override
  Widget build(BuildContext context) => _buildPage(context, context.watch<HelpViewModel>());

  Scaffold _buildPage(BuildContext context, HelpViewModel pageVM) => Scaffold(
        appBar: AppBar(title: const Text("Help!")),
        body: _buildPageBody(context, pageVM),
      );

  Widget _buildPageBody(BuildContext bodyContext, HelpViewModel pageVM) =>
      MarkdownWidget(data: pageVM.markDown);
}

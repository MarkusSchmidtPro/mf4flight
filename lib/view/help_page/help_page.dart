import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../command/i_command.dart';
import 'help_page_vm.dart';

class HelpPageArgs {
  const HelpPageArgs(this.helpContext, {this.values});

  final String helpContext;
  final Map<String, String>? values;
}

class HelpIcon extends StatelessWidget {
  const HelpIcon(this._helpContext, this._command);

  final String _helpContext;
  final ICommand _command;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.secondary),
        onPressed: () async => await _command.executeAsync(context, _helpContext));
  }
}

class HelpPage extends StatelessWidget {
  /* Private constructor to disallow ContactView instances.
     Instead ContactView.show( args) should be used to create
     a new ContactView with a bound ViewModel.
   */
  const HelpPage._();

  static StatelessWidget show(HelpPageArgs args) => ChangeNotifierProvider<HelpViewModel>(
        create: (_) => HelpViewModel()..init(args: args),
        child: const HelpPage._(),
      );

  @override
  Widget build(BuildContext context) => _buildPage(context, context.read<HelpViewModel>());

  Scaffold _buildPage(BuildContext context, HelpViewModel pageVM) => Scaffold(
        appBar: AppBar(title: const Text("Help!")),
        body: _buildPageBody(context, pageVM),
      );

  Widget _buildPageBody(BuildContext bodyContext, HelpViewModel pageVM) =>
      Markdown(data: pageVM.markDown);
}

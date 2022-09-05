import 'dart:core';

import 'package:flutter/material.dart';

import 'i_command.dart';


/// A implementation of a command that can never execute.
class InactiveCommand implements ICommand {

  bool canExecute() => false;

  Future<void> execute(BuildContext context, [dynamic p]) async {
    assert( true, "You can't execute an inactive command. Implement check for canExecute()!");
  }
}

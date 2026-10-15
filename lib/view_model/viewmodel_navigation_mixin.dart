import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../locator.dart';

/// Mixin providing navigation capabilities to ViewModels.
mixin ViewModelNavigationMixin {
  Logger get logger;

  /// Navigate to a named view.
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewNamedAsync<TResult>(String routeName, {Object? args}) async {
    logger.finest(">$routeName show");
    final TResult? result = await navigator.pushNamed<TResult?>(routeName, arguments: args);
    logger.finest("<$routeName closed, result=$result");
    return result;
  }

  /// Navigate to a widget view directly.
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewAsync<TResult>(StatelessWidget view) async {
    final TResult? result = await navigator.push<TResult>(MaterialPageRoute(builder: (_) => view));
    logger.finest("$runtimeType closed, result=$result");
    return result;
  }

  /// Close the current view and return to the previous view, returning [result].
  void closeView<TResult>([TResult? result]) => navigator.pop(result);

  /// Close the current view returning a specific [result].
  void closeViewWithResult<TResult>(TResult? result) => navigator.pop(result);
}

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/services.dart';
import 'help_page.dart';
import '../../view_model/viewmodel_base.dart';

class HelpViewModel extends ViewModelBase<HelpPageArgs> {
  HelpViewModel() : super();

  String markDown = "---";

  Future<void> initAsync([HelpPageArgs? args]) async => markDown = await loadMarkdownAsync2(args!);

  Future<String> loadMarkdownAsync2(HelpPageArgs args) async {
    String md = await _getFromResourceAsync(args.helpContext);
    if (args.values != null && args.values!.isNotEmpty) {
      for (MapEntry<String, String> item in args.values!.entries) {
        md = md.replaceAll("{${item.key}}", item.value);
      }
    }
    return md;
  }

  static const String _resourcePath = "assets/help";
  static const String _imgPath = "(resource:$_resourcePath/img/";
  static final String _languageCode = Platform.localeName.split('_')[0];

  Map<String, dynamic>? _manifestMap;

  Future<bool> _resourceExists(String resourcePath) async {
    if (_manifestMap == null) {
      // AssetManifest.json contains all data about all assets that you add in pubspec.yaml
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      _manifestMap = json.decode(manifestContent);
    }
    return _manifestMap!.containsKey(resourcePath);
  }

  Future<String> _getFromResourceAsync(String helpContext) async {
    try {
      String path = "$_resourcePath/${helpContext}_$_languageCode.md";
      if (!await _resourceExists(path)) path = "$_resourcePath/${helpContext}_de.md";

      String md = await rootBundle.loadString(path);
      md = md.replaceAll("(img\\", _imgPath);
      return md.replaceAll("(img/", _imgPath);
    } catch (e) {
      return e.toString();
    }
  }
}

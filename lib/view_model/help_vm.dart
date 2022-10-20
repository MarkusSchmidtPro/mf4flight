import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/services.dart';
import '../view/help_page.dart';
import 'viewmodel_base.dart';

class HelpViewModel extends ViewModelBase with LazyLoad {
  final HelpPageArgs _args;

  static const String resourcePath = "assets/help";
  static const String imgPath = "(resource:$resourcePath/img/";
  static final String languageCode = Platform.localeName.split('_')[0];

  static Map<String, dynamic>? manifestMap;

  Future<bool> resourceExists(String resourcePath) async {
    if (manifestMap == null) {
      // AssetManifest.json contains all data about all assets that you add in pubspec.yaml
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      manifestMap = json.decode(manifestContent);
    }
    return manifestMap!.containsKey(resourcePath);
  }

  HelpViewModel(HelpPageArgs args) : _args = args ;

  String markDown = "---";

  @override
  Future<void> onLoadAsync() async {
    String md = await getHelpTextAsync(_args.helpContext);
    if( _args.values != null && _args.values!.isNotEmpty ){
      for( MapEntry<String, String> item in _args.values!.entries ){
        md = md.replaceAll("{${item.key}}", item.value);
      }
    }
    markDown = md;
  }

  Future<String> getHelpTextAsync(String helpContext) async {
    try {
      String path = "$resourcePath/${helpContext}_$languageCode.md";
      if (!await resourceExists(path)) path = "$resourcePath/${helpContext}_de.md";

      String md = await rootBundle.loadString(path);
      md = md.replaceAll("(img\\", imgPath);
      return md.replaceAll("(img/", imgPath);
    } catch (e) {
      return e.toString();
    }
  }
}

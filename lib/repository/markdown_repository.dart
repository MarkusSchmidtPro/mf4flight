import 'dart:io';
import 'package:flutter/services.dart' ;

class MarkdownRepository {
  static const String _resourcePath = "assets/help";
  static const String _imgPath = "(resource:$_resourcePath/img/";
  static final String _languageCode = Platform.localeName.split('_')[0];

  static Set<String>? _manifestAssets;

  Future<String> fromResource(String resourceKey, {Map<String, String>? values}) async {
    String markDown = await _getFromResourceAsync(resourceKey);
    if (values != null && values.isNotEmpty) {
      for (MapEntry<String, String> item in values.entries) {
        markDown = markDown.replaceAll("{${item.key}}", item.value);
      }
    }
    return markDown;
  }

  static Future<bool> _resourceExists(String resourcePath) async {
    _manifestAssets ??= (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets().toSet();
    return _manifestAssets!.contains(resourcePath);
  }

  static Future<String> _getFromResourceAsync(String helpContext) async {
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
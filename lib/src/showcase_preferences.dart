import 'package:shared_preferences/shared_preferences.dart';

class ShowcasePreferences {
  final sugar = '_sugar_ShowcasePreferences';

  final SharedPreferences _preferences;

  static Future<ShowcasePreferences> getInstance() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return ShowcasePreferences(sharedPreferences);
  }

  ShowcasePreferences(this._preferences);

  bool hasShowcaseEverShown(int id) {
    return _preferences.getBool(_getKeyFromId(id)) ?? false;
  }

  Future<bool> setShowcaseHasShown(int id) async {
    return await _preferences.setBool(_getKeyFromId(id), true);
  }

  String _getKeyFromId(int id) {
    return sugar + id.toString();
  }
}

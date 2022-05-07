import 'package:fuji/categoryselection/categories.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesPreference {
  static const SELECTEDCATEGORIES = "SELECTEDCATEGORIES";

  storeCategoryList(List<String> _selectedcategories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(SELECTEDCATEGORIES, _selectedcategories);
  }

  Future<List<String>> getUserCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(SELECTEDCATEGORIES) ??
        ['N','G','M','I','P','U','A','F','O','B','FB','K','S','T','C','R','H','W1','W2','E','L'];
  }

}

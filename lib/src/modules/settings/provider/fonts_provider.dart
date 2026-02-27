import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontFamilyProvider = StateNotifierProvider<FontFamilyNotifier, String?>(
  (ref) => FontFamilyNotifier(),
);

class FontFamilyNotifier extends StateNotifier<String?> {
  FontFamilyNotifier() : super(null) {
    _loadFontFamily();
  }

  Future<void> _loadFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('font_family');
  }

  Future<void> setFontFamily(String? fontFamily) async {
    state = fontFamily;
    final prefs = await SharedPreferences.getInstance();
    
    if (fontFamily != null) {
      await prefs.setString('font_family', fontFamily);
    } else {
      await prefs.remove('font_family');
    }
  }
}
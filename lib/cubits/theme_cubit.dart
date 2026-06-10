import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false);
  // 👆 false = light mode by default

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('isDarkMode') ?? false);
    // 👆 read saved theme from phone memory
    // if nothing saved yet, use false (light mode)
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state;
    // 👆 flip the current value
    // if it was true → becomes false
    // if it was false → becomes true
    emit(newValue);
    // 👆 announce the new theme
    await prefs.setBool('isDarkMode', newValue);
    // 👆 save to phone memory so it stays after app closes
  }
}

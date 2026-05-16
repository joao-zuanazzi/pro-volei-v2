import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _welcomeKey = 'provolei_onboarding_done';
  static const _matchTutorialKey = 'provolei_match_tutorial_done';

  static Future<bool> isWelcomeDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeKey) ?? false;
  }

  static Future<void> markWelcomeDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
  }

  static Future<bool> isMatchTutorialDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_matchTutorialKey) ?? false;
  }

  static Future<void> markMatchTutorialDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_matchTutorialKey, true);
  }

  /// Reseta ambos os flags — usar apenas em testes/debug.
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeKey);
    await prefs.remove(_matchTutorialKey);
  }
}

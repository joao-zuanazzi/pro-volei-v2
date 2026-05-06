import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_service.dart';
import 'services/storage_service.dart';
import 'services/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(ProVoleiApp(
    storageService: storageService,
    themeProvider: themeProvider,
  ));
}

class ProVoleiApp extends StatelessWidget {
  final StorageService storageService;
  final ThemeProvider themeProvider;

  const ProVoleiApp({
    super.key,
    required this.storageService,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storageService),
        ChangeNotifierProvider(create: (_) => GameService()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Pro Volei',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

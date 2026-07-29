import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_volei/services/game_service.dart';
import 'package:pro_volei/services/storage_service.dart';
import 'package:pro_volei/services/theme_provider.dart';
import 'package:pro_volei/screens/home_screen.dart';
import 'package:pro_volei/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads successfully and opens tutorial choice dialog', (WidgetTester tester) async {
    final storageService = StorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider(create: (_) => GameService()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen()),
      ),
    );

    await tester.pump();

    // Verifica elementos na tela inicial
    expect(find.text('INICIAR PARTIDA'), findsOneWidget);
    expect(find.text('TUTORIAL'), findsOneWidget);
    expect(find.text('Tutorial / Guia'), findsNothing);

    // Toca no botão em destaque do topo
    await tester.tap(find.text('TUTORIAL'));
    await tester.pumpAndSettle();

    // Verifica diálogo de opções de tutorial
    expect(find.text('Tutoriais'), findsOneWidget);
    expect(find.text('Guia de Boas-Vindas'), findsOneWidget);
    expect(find.text('Tutorial da Partida'), findsOneWidget);

    // Seleciona o Guia de Boas-Vindas
    await tester.tap(find.text('Guia de Boas-Vindas'));
    await tester.pumpAndSettle();

    // Verifica que abriu a tela de onboarding
    expect(find.text('Bem-vindo ao ProVolei'), findsOneWidget);
  });

  testWidgets('Navigates directly to interactive match tutorial from choice dialog', (WidgetTester tester) async {
    final storageService = StorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider(create: (_) => GameService()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen()),
      ),
    );

    await tester.pump();

    // Toca no botão de tutorial
    await tester.tap(find.text('TUTORIAL'));
    await tester.pumpAndSettle();

    // Seleciona o Tutorial da Partida
    await tester.tap(find.text('Tutorial da Partida'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verifica que abriu o tutorial de marcações interativas na partida
    expect(find.text('Placar ao vivo'), findsOneWidget);
  });
}

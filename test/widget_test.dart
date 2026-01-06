// Testes básicos do ProVolei
//
// Para rodar: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pro_volei/services/game_service.dart';
import 'package:pro_volei/services/storage_service.dart';
import 'package:pro_volei/screens/home_screen.dart';
import 'package:pro_volei/theme/app_theme.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Cria serviços mock
    final storageService = StorageService();

    // Build widget com providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider(create: (_) => GameService()),
        ],
        child: MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen()),
      ),
    );

    // Aguarda renderização
    await tester.pump();

    // Verifica que o app carregou
    expect(find.text('PRO VOLEI'), findsOneWidget);
  });
}

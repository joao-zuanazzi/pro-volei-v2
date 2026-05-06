# ProVolei v2 — Contexto do Projeto

## O que é este projeto?

ProVolei (Pró-Vôlei SPY) é um app Flutter para professores de educação física registrarem e analisarem partidas de vôlei em tempo real. Ele é o tema do TCC (Trabalho de Conclusão de Curso) do usuário João no curso de Ciência da Computação.

O app permite:
- Registrar pontos com tipo (saque, ataque, bloqueio, erro adversário), detalhe e jogador
- Gerenciar equipes e atletas
- Gerar relatórios PDF por set e por partida completa
- Compartilhar PDFs via WhatsApp/Email (share_plus)
- Salvar/retomar partidas interrompidas
- Trocar entre tema claro e escuro

## Regras importantes para contribuir

### Idioma
- **TODO o código** (variáveis, comentários, nomes de métodos) está em **português brasileiro**, EXCETO palavras-chave do Dart/Flutter.
- Sempre manter esse padrão. Labels de UI, textos do app, comentários — tudo em PT-BR.

### Padrões de tema
- **NUNCA** use `context.watch<ThemeProvider>()` diretamente. Use `AppTheme.of(context)` que internamente usa `context.read()`.
- A reatividade do tema é garantida pelo `Consumer<ThemeProvider>` no `MaterialApp` (em `main.dart`).
- `AppTheme.of(context)` retorna `AppThemeColors` — use as propriedades dele (`.text`, `.textSecondary`, `.card`, `.surface`, `.dialogBackground`, `.cancelButton`, etc.) em vez de cores hardcoded como `Colors.white`, `Colors.white70`, `Colors.black87`.
- Cores fixas que NÃO mudam entre temas: `AppTheme.primaryBlue`, `AppTheme.primaryGold`, `AppTheme.success`, `AppTheme.error`, `AppTheme.warning`, `AppTheme.team1Color`, `AppTheme.team2Color`.
- Botões com gradiente (INICIAR, FINALIZAR SET, etc.) mantêm texto branco sempre — são botões de ação com fundo colorido.

### Padrões de Provider
- Gerenciamento de estado via `Provider` (ChangeNotifier).
- Providers: `GameService`, `StorageService`, `ThemeProvider`.
- SEMPRE use `context.read<X>()` em event handlers, `context.watch<X>()` apenas em `build()`.

### Padrões de UI
- Dialogs usam `AlertDialog` com `backgroundColor: colors.dialogBackground`, `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))`.
- Botões CANCELAR/FECHAR usam `TextStyle(color: colors.cancelButton)`.
- Todos os botões "destrutivos" (EXCLUIR, SAIR SEM SALVAR) usam `AppTheme.error`.
- Fundo de todas as telas: `BoxDecoration(gradient: colors.backgroundGradient)`.

### Estrutura de arquivos
```
lib/
├── main.dart                    # Entry point, MultiProvider, MaterialApp
├── models/
│   ├── match_report.dart        # Modelo de relatório salvo
│   ├── player.dart              # Modelo de jogador
│   ├── point.dart               # Modelo de ponto registrado
│   ├── point_type.dart          # Enum PointType + PointDetail
│   ├── set_data.dart            # Dados de um set
│   ├── team.dart                # Modelo de equipe
│   └── team_stats.dart          # Estatísticas acumuladas
├── screens/
│   ├── home_screen.dart         # Tela inicial + MatchSetupDialog
│   ├── match_screen.dart        # Tela principal da partida
│   ├── reports_screen.dart      # Listagem de relatórios
│   ├── team_editor_screen.dart  # Editor de equipe + _PlayerDialog
│   └── team_list_screen.dart    # Lista de equipes
├── services/
│   ├── game_service.dart        # Lógica do jogo (ChangeNotifier)
│   ├── pdf_service.dart         # Geração de PDFs
│   ├── report_storage_service.dart  # Persistência de relatórios
│   ├── storage_service.dart     # Persistência de equipes (Hive)
│   └── theme_provider.dart      # Gerenciador de tema (ChangeNotifier)
├── theme/
│   └── app_theme.dart           # ThemeData + AppThemeColors
└── widgets/
    ├── action_button.dart       # GradientButton + CircleActionButton
    ├── score_bar.dart           # ScoreDisplay (placar grande animado)
    ├── set_selector.dart        # Seletor visual de sets
    └── team_panel.dart          # Painel de registro de pontos
```

### Ambiente de desenvolvimento
- **Flutter**: 3.38.4 (stable) — SDK ^3.9.2
- **OS**: Windows 10/11
- **Teste rápido**: `flutter run -d windows`
- **Android**: Build para Android requer Android Studio instalado (JDK configurado)
- **Git remote**: https://github.com/joao-zuanazzi/pro-volei-v2.git

### Dependências principais
- `provider: ^6.1.2` — State management
- `pdf: ^3.11.0` / `printing: ^5.12.0` — Geração de PDFs
- `share_plus: ^10.1.4` — Compartilhamento nativo (usa `Share.shareXFiles`, NÃO `SharePlus.instance`)
- `hive` / `hive_flutter` — Persistência local
- `shared_preferences` — Preferências (tema)
- `open_file` — Abrir PDFs
- `path_provider` — Diretórios do sistema
- `intl` — Formatação de datas

## Estado atual do código

### ⚠️ MUDANÇAS NÃO COMMITADAS
O branch `main` tem a feature **Tema Claro/Escuro** implementada mas NÃO commitada.
Arquivos modificados: `main.dart`, todas as screens, `app_theme.dart`, widgets, + novos: `theme_provider.dart`, `assets/logo_dark.png`.

**Antes de trabalhar, faça commit dessas mudanças:**
```bash
git add .
git commit -m "feat: tema claro/escuro com toggle na home screen"
git push origin main
```

### Features implementadas ✅
1. Sistema completo de registro de partida (pontos, sets, times)
2. Gerenciamento de equipes e atletas (CRUD)
3. Geração de PDFs (por set e partida completa)
4. Compartilhar PDFs via WhatsApp/Email
5. Salvar/retomar partidas interrompidas
6. Tema claro/escuro com toggle (☀️/🌙 na home screen)
7. Timer de partida
8. Swap de equipes (VS clicável)

### Leia: docs/ROADMAP.md para o que falta fazer.
### Leia: docs/HISTORICO.md para decisões passadas e gotchas.

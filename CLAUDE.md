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
├── main.dart                       # Entry point: MultiProvider + Consumer<ThemeProvider> + MaterialApp
├── models/
│   ├── match_report.dart           # Metadados de uma partida salva (PDFs + snapshot)
│   ├── match_stats_snapshot.dart   # "Foto" estatística da partida (base do Dashboard)
│   ├── player.dart                 # Modelo de jogador (+ PlayerAdapter Hive)
│   ├── point.dart                  # Modelo de ponto registrado
│   ├── point_type.dart             # Enums PointType + PointDetail (labels PT-BR)
│   ├── set_data.dart               # Dados de um set (pontos, vencedor, duração)
│   ├── team.dart                   # Modelo de equipe (+ TeamAdapter Hive)
│   └── team_stats.dart             # Estatísticas acumuladas de uma equipe
├── screens/
│   ├── startup_screen.dart         # Splash/roteamento: decide onboarding vs home
│   ├── onboarding_screen.dart      # Tela de boas-vindas (6 slides), 1º uso
│   ├── home_screen.dart            # Tela inicial + MatchSetupDialog
│   ├── match_screen.dart           # Tela principal da partida
│   ├── dashboard_screen.dart       # Dashboard de estatísticas históricas (fl_chart)
│   ├── reports_screen.dart         # Listagem de relatórios
│   ├── team_editor_screen.dart     # Editor de equipe + _PlayerDialog
│   └── team_list_screen.dart       # Lista de equipes
├── services/
│   ├── game_service.dart           # Lógica do jogo (ChangeNotifier)
│   ├── onboarding_service.dart     # Flags de tutorial (SharedPreferences)
│   ├── pdf_service.dart            # Geração de PDFs
│   ├── report_storage_service.dart # Persistência de relatórios (JSON em arquivo)
│   ├── storage_service.dart        # Persistência de equipes (Hive)
│   └── theme_provider.dart         # Gerenciador de tema (ChangeNotifier)
├── theme/
│   └── app_theme.dart              # ThemeData + AppThemeColors
└── widgets/
    ├── action_button.dart          # GradientButton + CircleActionButton
    ├── coach_mark_overlay.dart     # Tutorial contextual (coach mark) na partida
    ├── score_bar.dart              # ScoreDisplay (placar grande animado)
    ├── set_selector.dart           # Seletor visual de sets (progressivo)
    └── team_panel.dart             # Painel de registro de pontos
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

Versão exibida no app: **3.0**. Fases 3, 4 e 5 concluídas e commitadas na `main`
(branch de trabalho). Build Android (APK) e Windows (desktop) funcionando.

### Features implementadas ✅
1. Registro completo de partida (pontos por tipo/detalhe/jogador, sets, times)
2. Gerenciamento de equipes e atletas (CRUD via Hive)
3. Geração de PDFs (por set e partida completa) + compartilhamento (WhatsApp/Email)
4. Salvar/retomar partidas interrompidas
5. Tema claro/escuro com toggle (☀️/🌙 na home screen), persistido
6. Cronômetro iniciar/pausar; swap de lados ("Trocar"); desfazer último ponto
7. Dashboard de estatísticas históricas com gráficos (fl_chart)
8. Onboarding de primeiro uso: tela de boas-vindas (6 slides) + coach mark na partida
9. Rodada extensa de melhorias de UX (Fase 5, heurísticas de Nielsen): fade entre
   telas, haptic feedback, tooltips, set selector progressivo, contraste WCAG AA,
   cards de navegação clicáveis, diálogos revisados, escala de espaçamento de 4px

### Leia: docs/ROADMAP.md para o que ainda falta fazer.
### Leia: docs/HISTORICO.md para decisões passadas e gotchas.

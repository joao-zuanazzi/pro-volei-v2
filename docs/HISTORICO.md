# Histórico de Decisões & Gotchas — ProVolei v2

Este documento registra decisões de design, bugs corrigidos e armadilhas para que futuras sessões de desenvolvimento não repitam erros.

---

## 🎨 Design & UI

### Cores de time
- `team1Color` (azul `#3D5A80`) e `team2Color` (amarelo `#E8C468`) são as cores padrão.
- Quando o usuário seleciona equipes cadastradas, cada equipe carrega sua própria `primaryColor`.
- **Se ambas as equipes tiverem a mesma cor**, o código em `home_screen.dart` (MatchSetupDialog) força a equipe 2 para a cor padrão `Team.team2Default`.

### Swap de equipes
- O botão VS no placar é clicável e chama `game.swapTeams()`.
- As cores nos painéis, placar e tabs devem acompanhar o swap — usa-se `game.team1.primaryColor` e `game.team2.primaryColor` dinamicamente (NUNCA constantes `AppTheme.team1Color`).

### Botões CANCELAR/FECHAR
- **Decisão**: Todos os botões CANCELAR e FECHAR usam `colors.cancelButton` (branco 70% no dark, cinza no light). Isso foi padronizado após feedback do usuário que reclamou da baixa visibilidade.

### Barras coloridas nos cards
- Foram implementadas e REMOVIDAS por feedback do usuário. Não ficaram boas visualmente. Em vez disso, usamos dots coloridos nas tabs.

### Modo paisagem
- O `MatchScreen` detecta `constraints.maxHeight >= 650` para decidir entre layout expandido vs scroll compacto.
- O `ScoreDisplay` usa padding reduzido (4px) no modo compacto.
- TeamPanel ocupa 55% da altura disponível no modo paisagem.

---

## 🐛 Bugs corrigidos e armadilhas

### ParentDataWidget crash
- **Causa**: `Expanded` usado diretamente dentro de `Container` (que não é `Flex`).
- **Solução**: Em `team_panel.dart`, quando `isExpanded=true`, o content é envolto em `Column(children: [Expanded(child: content)])` para que Expanded tenha um pai Flex válido.
- **Arquivo**: `lib/widgets/team_panel.dart`, linhas ~87-90

### Provider watch vs read
- **Causa**: `AppTheme.of(context)` usava `context.watch<ThemeProvider>()` que só funciona dentro de `build()`. Event handlers (onPressed, onPopInvoked, etc.) chamavam `AppTheme.of()` e crashavam.
- **Solução**: `AppTheme.of()` agora usa `context.read()` internamente. A reatividade é garantida pelo `Consumer<ThemeProvider>` no `MaterialApp` que reconstrói toda a árvore ao trocar o tema.
- **REGRA**: NUNCA use `context.watch<ThemeProvider>()` diretamente. Sempre `AppTheme.of(context)`.

### HomeScreen é const → Consumer<ThemeProvider> sozinho NÃO reconstrói ela
- **Armadilha**: A regra acima ("AppTheme.of(context) basta porque o Consumer reconstrói tudo") tem uma exceção: em `main.dart`, `home: const HomeScreen()`. Quando o `Consumer<ThemeProvider>` rebuilda o `MaterialApp`, a HomeScreen const é considerada idêntica e NÃO é reconstruída. Como `AppTheme.of()` usa `context.read()`, a HomeScreen não se inscreve no provider — então cores, logo e o ícone do toggle ficam congelados ao trocar de tema.
- **Solução**: `_buildThemeToggle` em `home_screen.dart` chama `context.watch<ThemeProvider>()` recebendo o context da HomeScreen via parâmetro, o que inscreve a tela inteira. Esse watch é uma EXCEÇÃO INTENCIONAL à regra acima — está documentado em comentário no código.
- **Outras telas (match, reports, team_*)**: funcionam porque são pushed via `Navigator.push` (sem `const`), então rebuildam ao serem navegadas e Material widgets internos respondem ao `Theme.of(context)`.
- **Se for adicionar uma nova tela acessível como `home:` const no MaterialApp** ou se notar que toggle de tema não atualiza alguma tela: incluir um `context.watch<ThemeProvider>()` em algum ponto da `build()` dela.

### share_plus API
- **Versão**: `share_plus: ^10.1.4`
- **API correta**: `Share.shareXFiles([XFile(path)], subject: '...')`
- **API ERRADA** (NÃO usar): `SharePlus.instance.share(ShareParams(...))` — essa API só existe em versões >= 11.x
- Verificar se precisar atualizar a lib no futuro.

### JAVA_HOME / Android Build
- O usuário desinstalou o Android Studio acidentalmente.
- Reinstalou, mas o JAVA_HOME pode ainda apontar para JDK antigo (`C:\Program Files\Microsoft\jdk-17.0.18.8-hotspot`).
- **Fix**: Verificar `flutter doctor` e apontar JAVA_HOME para o JDK bundled do Android Studio (normalmente `C:\Program Files\Android\Android Studio\jbr`).

---

## 📐 Arquitetura

### GameService
- Gerencia TODO o estado da partida: times, sets, pontos, timer, seleções.
- `ChangeNotifier` — notifica widgets via Provider.
- `saveMatchState()` / `loadMatchState()` — persistência de partida via SharedPreferences (JSON serialization).
- `swapTeams()` — troca team1 e team2 completamente.
- `generateRandomPoints(count)` — função de teste, ativada por long press no timer.

### PdfService
- Classe estática, não gerenciada por Provider.
- Gera PDFs com `dart:pdf` e salva via `path_provider`.
- `generateSetPdf()` — relatório de um set
- `generateMatchPdf()` — relatório completo da partida
- **Nota**: Usa fontes Helvetica built-in (sem suporte Unicode completo — acentos podem ter issues em alguns dispositivos).

### StorageService
- Persistência de equipes via Hive.
- `ChangeNotifier` — lista de equipes reativa.

### ThemeProvider
- Gerencia `isDarkMode` com persistência via SharedPreferences.
- `toggleTheme()` — alterna e salva.
- Inicializado no `main()` antes do `runApp()`.

---

## 🎓 Contexto acadêmico (TCC)
- Aluno: João Zuanazzi
- Curso: Ciência da Computação
- O projeto é avaliado por professores de educação física que usam o app em aulas práticas.
- Um questionário de usabilidade baseado nas heurísticas de Nielsen já foi elaborado.
- O app precisa ser intuitivo para professores com baixo letramento digital.

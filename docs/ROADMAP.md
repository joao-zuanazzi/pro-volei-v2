# Roadmap — ProVolei v2

> Estado em junho/2026. Versão exibida no app: **3.0**. As Fases 3, 4 e 5 estão
> concluídas e commitadas na `main`. Esta lista cobre o que ainda falta.

---

## ✅ Concluído

### Fase 3 — Tema Claro/Escuro
- Toggle na home screen; todas as telas e widgets com cores dinâmicas via `AppThemeColors`.
- Tema claro com off-white nos cards (`#FAFBFC`) e borders suaves; contraste WCAG AA
  ajustado no `textTertiary`. Preferência persistida (SharedPreferences).

### Fase 4 — Dashboard de Estatísticas
- [x] Tela de dashboard com gráficos (`DashboardScreen`).
- [x] Estatísticas por equipe (total de pontos por tipo).
- [x] Comparativo histórico entre partidas (evolução por equipe).
- [x] Gráficos visuais (linha + barras com `fl_chart`).
- [x] Snapshot estatístico persistido junto do `MatchReport` (`MatchStatsSnapshot`).
- [x] Top jogadores por pontos (saque + ataque + bloqueio agregados).
- [x] Desempenho por adversário (V/E/D, pontos pró/contra).
- [x] "Quem mais erra" — atribuição de erros ao jogador adversário (`errosCometidos`).
- [x] Sparklines com escala individual, linha de média, contexto "vs partida anterior"
  e aviso de amostra pequena.

### Fase 5 — Melhorias de UX (auditoria de design por heurísticas de Nielsen)
Praticamente toda concluída. Implementado e commitado:

**Críticos**
- [x] Remover long-press de pontos aleatórios no timer (feature de debug exposta).
- [x] Resolver fonte Poppins — referências removidas; usa fonte do sistema.
- [x] Hierarquizar botões do rodapé do `match_screen` ("FINALIZAR JOGO" em destaque).
- [x] Trocar ícone "voltar" do `match_screen` por X (close) + tooltip.

**Importantes**
- [x] Home: cards de navegação clicáveis (Equipes / Relatórios / Dashboard).
- [x] Renomear "EXCLUIR" → "DESFAZER" com ícone `undo` no `team_panel.dart`.
- [x] Tornar o swap de lados descobrível (botão "Trocar" com label + tooltip).
- [x] Aumentar áreas de toque (editar nome da partida, ícones do header).
- [x] Modo claro: off-white nos cards e borders mais sutis.
- [x] Contraste WCAG AA no modo claro.
- [x] Escala de espaçamento em múltiplos de 4 (4/8/12/16/24/32).
- [x] Haptic feedback ao registrar ponto (`HapticFeedback.lightImpact()`).
- [x] Animação correta do score (anima o delta anterior→novo, não 0→N).
- [x] SetSelector progressivo (mostra só os sets relevantes).
- [x] Tooltips em todos os botões ícone-only.
- [x] Onboarding de primeiro uso: welcome flow (6 slides) + coach mark na partida.

**Polimentos**
- [x] Suavizar `error` no modo claro (`#E53935` → `#D32F2F`).
- [x] Transições fade entre rotas (`PageRouteBuilder` + `FadeTransition`).

---

## 🟡 Pendências

### UX restante (itens da Fase 5 não concluídos)
- [ ] **Padronizar AppBar real em todas as telas.** Hoje `team_list` e `team_editor`
  usam `AppBar`; `home`, `match`, `reports` e `dashboard` montam o header manualmente
  em Stack/Column.
- [ ] **Escala tipográfica fixa.** O app ainda usa 16+ tamanhos de fonte diferentes.
  Definir caption(11), body(13), body-strong(14), title(16), heading(20), display(28).
- [ ] **`letterSpacing` consistente** (hoje varia entre 0.3, 0.5, 1, 2 sem padrão).
- [ ] **Suporte a text scaling do sistema.** `fontSize` é hardcoded; usuários com fonte
  ampliada no Android não veem mudança.

> **Decisão registrada:** a ideia de substituir o snackbar "Ponto registrado" por um
> flash animado no placar foi **tentada e revertida** (não agradou). Mantém-se o
> snackbar curto de confirmação. Ver `HISTORICO.md`.

### Layout — Modo paisagem
- [ ] **`MatchScreen` em landscape** ainda tem problemas de espaçamento entre placar e cards.
- [ ] Em landscape, ao fazer swap, as cores no placar de cima e os labels "Equipe 1/2"
  nas tabs podem não acompanhar corretamente.

> Obs.: o onboarding (welcome flow + coach marks) já tem suporte a landscape.

### Build
- [x] Build Android (APK) funcionando — `--release --split-per-abi --obfuscate`.
  (`flutter doctor` pode acusar `cmdline-tools` faltando / licenças, mas o build de APK
  funciona; se travar, cheque o `JAVA_HOME` apontando para o JDK do Android Studio.)
- [x] Build Windows (desktop) funcionando — `flutter build windows --release`.

---

## 🚀 Fase 6 — Exportação e Compartilhamento avançado (futuro)
- [ ] Exportar dados em CSV/Excel.
- [ ] Histórico de partidas com busca/filtro.
- [ ] Backup/restore de dados.

---

## 📋 Backlog de bugs/melhorias conhecidos

| Prioridade | Item | Arquivo |
|------------|------|---------|
| Média | `_buildPlayerErrorsTable` não utilizado | pdf_service.dart |
| Média | `_buildChartSection` não utilizado | pdf_service.dart |
| Baixa | `invalid_null_aware_operator` warnings | pdf_service.dart |
| Baixa | `avoid_print` | pdf_service.dart, report_storage_service.dart |
| Info | `use_build_context_synchronously` | reports_screen.dart |

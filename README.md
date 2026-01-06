# 🏐 ProVolei

Aplicativo para gerenciar partidas de vôlei. Feito em Flutter.

## O que faz?

- Registra pontos de cada equipe (saque, bloqueio, ataque, erro)
- Mostra estatísticas por jogador
- Gera relatórios em PDF (por set ou partida completa)
- Salva o histórico de partidas para consultar depois

## Rodando o projeto

```bash
# Instalar dependências
flutter pub get

# Rodar no dispositivo conectado
flutter run
```

## Gerando ícones

Se precisar atualizar os ícones do app:

```bash
flutter pub run flutter_launcher_icons
```

## Estrutura

```
lib/
├── models/       # Team, Player, Point, etc.
├── screens/      # Telas do app
├── services/     # Game, PDF, Storage
├── widgets/      # Componentes reutilizáveis
└── theme/        # Cores e estilos
```

## Build

```bash
# APK para Android
flutter build apk

# Windows
flutter build windows
```

---

Desenvolvido pelo PET Computação UFMS:
João Victor Zuanazzi Lourenço
Caio Kwiatkoski Mendes

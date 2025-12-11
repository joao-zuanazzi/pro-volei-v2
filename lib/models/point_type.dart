/// Tipos de ponto no vôlei
enum PointType {
  serve('Saque', '🏐'),
  block('Bloqueio', '🛡️'),
  attack('Ataque', '⚡'),
  opponentError('Erro do Adversário', '❌');

  const PointType(this.label, this.icon);

  final String label;
  final String icon;
}

/// Origem do ponto
enum PointOrigin {
  sideOut('Side-out'),
  counterAttack('Contra-ataque');

  const PointOrigin(this.label);

  final String label;
}

class MembroEscola {
  const MembroEscola({
    required this.id,
    required this.escolaId,
    required this.userId,
    this.email,
    required this.papel,
    required this.createdAt,
  });

  final String id;
  final String escolaId;
  final String userId;
  final String? email;
  final String papel;
  final DateTime createdAt;

  bool get isCoordenador => papel == 'coordenador';
}

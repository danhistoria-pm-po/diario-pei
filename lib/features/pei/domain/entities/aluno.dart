class Aluno {
  const Aluno({
    required this.id,
    required this.professorId,
    required this.nome,
    required this.turma,
    this.diagnostico,
    this.observacoes,
    required this.criadoEm,
  });

  final String id;
  final String professorId;
  final String nome;
  final String turma;
  final String? diagnostico;
  final String? observacoes;
  final DateTime criadoEm;

  Aluno copyWith({
    String? id,
    String? professorId,
    String? nome,
    String? turma,
    String? diagnostico,
    String? observacoes,
    DateTime? criadoEm,
  }) {
    return Aluno(
      id: id ?? this.id,
      professorId: professorId ?? this.professorId,
      nome: nome ?? this.nome,
      turma: turma ?? this.turma,
      diagnostico: diagnostico ?? this.diagnostico,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}

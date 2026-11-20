class RegistroDiario {
  const RegistroDiario({
    required this.id,
    required this.alunoId,
    required this.professorId,
    required this.dataRegistro,
    required this.categoria,
    required this.descricao,
    required this.criadoEm,
  });

  final String id;
  final String alunoId;
  final String professorId;
  final DateTime dataRegistro;
  final String categoria;
  final String descricao;
  final DateTime criadoEm;

  RegistroDiario copyWith({
    String? id,
    String? alunoId,
    String? professorId,
    DateTime? dataRegistro,
    String? categoria,
    String? descricao,
    DateTime? criadoEm,
  }) {
    return RegistroDiario(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      professorId: professorId ?? this.professorId,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}

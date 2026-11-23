const List<String> kDisciplinasEscolares = <String>[
  'Geral / AEE',
  'Língua Portuguesa',
  'Matemática',
  'História',
  'Geografia',
  'Ciências',
  'Biologia',
  'Física',
  'Química',
  'Inglês',
  'Arte',
  'Educação Física',
  'Filosofia',
  'Sociologia',
  'Outra',
];

class RegistroDiario {
  const RegistroDiario({
    required this.id,
    required this.alunoId,
    required this.professorId,
    this.autorEmail,
    this.disciplina,
    required this.dataRegistro,
    required this.categoria,
    required this.descricao,
    required this.criadoEm,
  });

  final String id;
  final String alunoId;
  final String professorId;
  final String? autorEmail;
  final String? disciplina;
  final DateTime dataRegistro;
  final String categoria;
  final String descricao;
  final DateTime criadoEm;

  RegistroDiario copyWith({
    String? id,
    String? alunoId,
    String? professorId,
    String? autorEmail,
    String? disciplina,
    DateTime? dataRegistro,
    String? categoria,
    String? descricao,
    DateTime? criadoEm,
  }) {
    return RegistroDiario(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      professorId: professorId ?? this.professorId,
      autorEmail: autorEmail ?? this.autorEmail,
      disciplina: disciplina ?? this.disciplina,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}

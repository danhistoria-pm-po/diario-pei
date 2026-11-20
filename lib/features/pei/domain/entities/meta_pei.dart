enum StatusMetaPei {
  pendente('pendente', 'Pendente'),
  emAndamento('em_andamento', 'Em andamento'),
  atingida('atingida', 'Atingida');

  const StatusMetaPei(this.value, this.label);

  final String value;
  final String label;

  static StatusMetaPei fromValue(String? value) {
    for (final status in StatusMetaPei.values) {
      if (status.value == value) {
        return status;
      }
    }
    return StatusMetaPei.pendente;
  }
}

class MetaPei {
  const MetaPei({
    required this.id,
    required this.alunoId,
    required this.professorId,
    required this.area,
    required this.titulo,
    this.descricao,
    required this.status,
    this.prazo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final String id;
  final String alunoId;
  final String professorId;
  final String area;
  final String titulo;
  final String? descricao;
  final StatusMetaPei status;
  final DateTime? prazo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  MetaPei copyWith({
    String? id,
    String? alunoId,
    String? professorId,
    String? area,
    String? titulo,
    String? descricao,
    StatusMetaPei? status,
    DateTime? prazo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return MetaPei(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      professorId: professorId ?? this.professorId,
      area: area ?? this.area,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      status: status ?? this.status,
      prazo: prazo ?? this.prazo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}

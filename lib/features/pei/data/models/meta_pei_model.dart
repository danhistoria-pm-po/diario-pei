import '../../domain/entities/meta_pei.dart';

class MetaPeiModel extends MetaPei {
  const MetaPeiModel({
    required super.id,
    required super.alunoId,
    required super.professorId,
    required super.area,
    required super.titulo,
    super.descricao,
    required super.status,
    super.prazo,
    required super.criadoEm,
    required super.atualizadoEm,
  });

  factory MetaPeiModel.fromMap(Map<String, dynamic> map) {
    final prazoRaw = map['prazo'] as String?;
    return MetaPeiModel(
      id: map['id'] as String,
      alunoId: map['aluno_id'] as String,
      professorId: map['professor_id'] as String,
      area: map['area'] as String,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String?,
      status: StatusMetaPei.fromValue(map['status'] as String?),
      prazo: prazoRaw != null && prazoRaw.isNotEmpty
          ? DateTime.parse(prazoRaw)
          : null,
      criadoEm: DateTime.parse(map['criado_em'] as String),
      atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'aluno_id': alunoId,
      'professor_id': professorId,
      'area': area,
      'titulo': titulo,
      'descricao': descricao,
      'status': status.value,
      'prazo': prazo != null ? formatDateOnly(prazo!) : null,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }

  static String formatDateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

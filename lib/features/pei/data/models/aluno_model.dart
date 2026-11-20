import '../../domain/entities/aluno.dart';

class AlunoModel extends Aluno {
  const AlunoModel({
    required super.id,
    required super.professorId,
    required super.nome,
    required super.turma,
    super.diagnostico,
    super.observacoes,
    required super.criadoEm,
  });

  factory AlunoModel.fromMap(Map<String, dynamic> map) {
    return AlunoModel(
      id: map['id'] as String,
      professorId: map['professor_id'] as String,
      nome: map['nome'] as String,
      turma: map['turma'] as String,
      diagnostico: map['diagnostico'] as String?,
      observacoes: map['observacoes'] as String?,
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'professor_id': professorId,
      'nome': nome,
      'turma': turma,
      'diagnostico': diagnostico,
      'observacoes': observacoes,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}

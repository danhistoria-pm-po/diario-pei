import '../../domain/entities/registro_diario.dart';
import 'meta_pei_model.dart';

class RegistroDiarioModel extends RegistroDiario {
  const RegistroDiarioModel({
    required super.id,
    required super.alunoId,
    required super.professorId,
    super.autorEmail,
    required super.dataRegistro,
    required super.categoria,
    required super.descricao,
    required super.criadoEm,
  });

  factory RegistroDiarioModel.fromMap(Map<String, dynamic> map) {
    return RegistroDiarioModel(
      id: map['id'] as String,
      alunoId: map['aluno_id'] as String,
      professorId: map['professor_id'] as String,
      autorEmail: map['autor_email'] as String?,
      dataRegistro: DateTime.parse(map['data_registro'] as String),
      categoria: map['categoria'] as String,
      descricao: map['descricao'] as String,
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'aluno_id': alunoId,
      'professor_id': professorId,
      'autor_email': autorEmail,
      'data_registro': MetaPeiModel.formatDateOnly(dataRegistro),
      'categoria': categoria,
      'descricao': descricao,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}

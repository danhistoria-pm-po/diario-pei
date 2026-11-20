import '../../domain/entities/escola.dart';

class EscolaModel extends Escola {
  const EscolaModel({
    required super.id,
    required super.nome,
    required super.codigoConvite,
    required super.papelUsuario,
  });

  factory EscolaModel.fromMap(Map<String, dynamic> map) {
    final escolaNested = map['escolas'];
    if (escolaNested is Map) {
      final escolaMap = Map<String, dynamic>.from(escolaNested);
      return EscolaModel(
        id: escolaMap['id'] as String,
        nome: escolaMap['nome'] as String,
        codigoConvite: escolaMap['codigo_convite'] as String,
        papelUsuario: (map['papel'] as String?) ?? 'professor',
      );
    }

    return EscolaModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      codigoConvite: map['codigo_convite'] as String,
      papelUsuario:
          (map['papel_usuario'] as String?) ??
          (map['papel'] as String?) ??
          'professor',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'codigo_convite': codigoConvite,
      'papel_usuario': papelUsuario,
    };
  }
}

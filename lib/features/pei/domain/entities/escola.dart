class Escola {
  const Escola({
    required this.id,
    required this.nome,
    required this.codigoConvite,
    required this.papelUsuario,
  });

  final String id;
  final String nome;
  final String codigoConvite;
  final String papelUsuario;

  Escola copyWith({
    String? id,
    String? nome,
    String? codigoConvite,
    String? papelUsuario,
  }) {
    return Escola(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      codigoConvite: codigoConvite ?? this.codigoConvite,
      papelUsuario: papelUsuario ?? this.papelUsuario,
    );
  }
}

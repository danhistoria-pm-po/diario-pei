import 'dart:js_interop';

@JS('exportarParecerDoc')
external void _exportarParecerDoc(
  String tituloArquivo,
  String nomeEscola,
  String nomeAluno,
  String turma,
  String conteudoTexto,
);

@JS('exportarParecerPdf')
external void _exportarParecerPdf(
  String nomeEscola,
  String nomeAluno,
  String turma,
  String conteudoTexto,
);

void exportarParecerDocPlatform(
  String tituloArquivo,
  String nomeEscola,
  String nomeAluno,
  String turma,
  String conteudoTexto,
) {
  _exportarParecerDoc(
    tituloArquivo,
    nomeEscola,
    nomeAluno,
    turma,
    conteudoTexto,
  );
}

void exportarParecerPdfPlatform(
  String nomeEscola,
  String nomeAluno,
  String turma,
  String conteudoTexto,
) {
  _exportarParecerPdf(nomeEscola, nomeAluno, turma, conteudoTexto);
}

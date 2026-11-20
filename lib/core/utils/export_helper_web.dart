import 'dart:js_interop';

@JS('exportarParecerDoc')
external void _exportarParecerDoc(
  String tituloArquivo,
  String nomeAluno,
  String turma,
  String conteudoTexto,
);

@JS('exportarParecerPdf')
external void _exportarParecerPdf(
  String nomeAluno,
  String turma,
  String conteudoTexto,
);

void exportarParecerDocPlatform(
  String tituloArquivo,
  String nomeAluno,
  String turma,
  String conteudoTexto,
) {
  _exportarParecerDoc(tituloArquivo, nomeAluno, turma, conteudoTexto);
}

void exportarParecerPdfPlatform(
  String nomeAluno,
  String turma,
  String conteudoTexto,
) {
  _exportarParecerPdf(nomeAluno, turma, conteudoTexto);
}

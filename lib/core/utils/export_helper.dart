import 'export_helper_stub.dart'
    if (dart.library.js_interop) 'export_helper_web.dart'
    as platform;

class ExportHelper {
  ExportHelper._();

  static const Map<String, String> _acentosMap = <String, String>{
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'Á': 'A',
    'À': 'A',
    'Â': 'A',
    'Ã': 'A',
    'Ä': 'A',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'É': 'E',
    'È': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'Í': 'I',
    'Ì': 'I',
    'Î': 'I',
    'Ï': 'I',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'Ó': 'O',
    'Ò': 'O',
    'Ô': 'O',
    'Õ': 'O',
    'Ö': 'O',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'Ú': 'U',
    'Ù': 'U',
    'Û': 'U',
    'Ü': 'U',
    'ç': 'c',
    'Ç': 'C',
    'ñ': 'n',
    'Ñ': 'N',
  };

  static String sanitizarNomeArquivo(String nomeAluno) {
    final buffer = StringBuffer();
    for (final rune in nomeAluno.trim().runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_acentosMap[char] ?? char);
    }

    final limpo = buffer
        .toString()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final base = limpo.isEmpty ? 'Aluno' : limpo;
    return 'PEI_$base.doc';
  }

  static void exportarDoc({
    String? nomeEscola,
    required String nomeAluno,
    required String turma,
    required String conteudoTexto,
  }) {
    final tituloArquivo = sanitizarNomeArquivo(nomeAluno);
    platform.exportarParecerDocPlatform(
      tituloArquivo,
      nomeEscola?.trim() ?? '',
      nomeAluno,
      turma,
      conteudoTexto,
    );
  }

  static void exportarPdf({
    String? nomeEscola,
    required String nomeAluno,
    required String turma,
    required String conteudoTexto,
  }) {
    platform.exportarParecerPdfPlatform(
      nomeEscola?.trim() ?? '',
      nomeAluno,
      turma,
      conteudoTexto,
    );
  }
}

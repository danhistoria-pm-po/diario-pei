import 'package:flutter/services.dart';

import '../../features/pei/domain/entities/aluno.dart';
import '../../features/pei/domain/entities/meta_pei.dart';
import '../../features/pei/domain/entities/registro_diario.dart';

class PeiSummaryFormatter {
  PeiSummaryFormatter._();

  static String formatDateBr(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  static String buildSummary({
    required Aluno aluno,
    required List<MetaPei> metas,
    required List<RegistroDiario> registros,
  }) {
    final buffer = StringBuffer()
      ..writeln('=== RESUMO DO DIÁRIO PEI ===')
      ..writeln('Aluno: ${aluno.nome}')
      ..writeln('Turma: ${aluno.turma}');

    if (aluno.diagnostico != null && aluno.diagnostico!.trim().isNotEmpty) {
      buffer.writeln('Diagnóstico / Necessidade: ${aluno.diagnostico!.trim()}');
    }
    if (aluno.observacoes != null && aluno.observacoes!.trim().isNotEmpty) {
      buffer.writeln('Observações: ${aluno.observacoes!.trim()}');
    }

    buffer
      ..writeln()
      ..writeln('--- METAS DO PEI (${metas.length}) ---');

    if (metas.isEmpty) {
      buffer.writeln('Nenhuma meta cadastrada.');
    } else {
      for (var i = 0; i < metas.length; i++) {
        final meta = metas[i];
        final prazoTexto = meta.prazo != null
            ? ' | Prazo: ${formatDateBr(meta.prazo!)}'
            : '';
        buffer.writeln(
          '${i + 1}. [${meta.status.label}] (${meta.area}) ${meta.titulo}$prazoTexto',
        );
        if (meta.descricao != null && meta.descricao!.trim().isNotEmpty) {
          buffer.writeln('   Detalhes: ${meta.descricao!.trim()}');
        }
      }
    }

    buffer
      ..writeln()
      ..writeln('--- DIÁRIO DE BORDO (${registros.length}) ---');

    if (registros.isEmpty) {
      buffer.writeln('Nenhum registro lançado.');
    } else {
      for (final registro in registros) {
        buffer.writeln(
          '- ${formatDateBr(registro.dataRegistro)} [${registro.categoria}]: ${registro.descricao}',
        );
      }
    }

    return buffer.toString().trimRight();
  }

  static Future<String> copySummaryToClipboard({
    required Aluno aluno,
    required List<MetaPei> metas,
    required List<RegistroDiario> registros,
  }) async {
    final summary = buildSummary(
      aluno: aluno,
      metas: metas,
      registros: registros,
    );
    await Clipboard.setData(ClipboardData(text: summary));
    return summary;
  }
}

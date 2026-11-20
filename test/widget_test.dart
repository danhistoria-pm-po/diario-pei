import 'package:diario_pei/app.dart';
import 'package:diario_pei/core/utils/export_helper.dart';
import 'package:diario_pei/core/utils/pei_summary_formatter.dart';
import 'package:diario_pei/features/pei/domain/entities/aluno.dart';
import 'package:diario_pei/features/pei/domain/entities/meta_pei.dart';
import 'package:diario_pei/features/pei/domain/entities/registro_diario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Exibe aviso de configuração quando Supabase não é informado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DiarioPeiApp(isSupabaseConfigured: false));
    expect(find.text('Configuração do Supabase pendente'), findsOneWidget);
  });

  test('PeiSummaryFormatter formata aluno, metas e diário corretamente', () {
    final now = DateTime(2026, 11, 20);
    final aluno = Aluno(
      id: 'a1',
      professorId: 'p1',
      nome: 'Lucas Mendes',
      turma: '4º Ano B',
      diagnostico: 'TEA',
      criadoEm: now,
    );
    final meta = MetaPei(
      id: 'm1',
      alunoId: 'a1',
      professorId: 'p1',
      area: 'Leitura',
      titulo: 'Ler frases curtas com apoio visual',
      status: StatusMetaPei.emAndamento,
      prazo: DateTime(2026, 12, 10),
      criadoEm: now,
      atualizadoEm: now,
    );
    final registro = RegistroDiario(
      id: 'r1',
      alunoId: 'a1',
      professorId: 'p1',
      dataRegistro: now,
      categoria: 'Avanço',
      descricao: 'Leu três frases completas com pictogramas.',
      criadoEm: now,
    );

    final resumo = PeiSummaryFormatter.buildSummary(
      aluno: aluno,
      metas: <MetaPei>[meta],
      registros: <RegistroDiario>[registro],
    );

    expect(resumo, contains('Aluno: Lucas Mendes'));
    expect(resumo, contains('[Em andamento] (Leitura) Ler frases curtas'));
    expect(resumo, contains('20/11/2026 [Avanço]'));
  });

  test('ExportHelper sanitiza nome do arquivo removendo acentos e espaços', () {
    expect(
      ExportHelper.sanitizarNomeArquivo('Paulo TESTE'),
      'PEI_Paulo_TESTE.doc',
    );
    expect(
      ExportHelper.sanitizarNomeArquivo('João Conceição Ávila'),
      'PEI_Joao_Conceicao_Avila.doc',
    );
  });
}

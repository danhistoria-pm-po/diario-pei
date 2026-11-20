import 'package:diario_pei/app.dart';
import 'package:diario_pei/core/utils/export_helper.dart';
import 'package:diario_pei/core/utils/pei_summary_formatter.dart';
import 'package:diario_pei/features/pei/data/models/aluno_model.dart';
import 'package:diario_pei/features/pei/data/models/escola_model.dart';
import 'package:diario_pei/features/pei/data/models/registro_diario_model.dart';
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

  test('EscolaModel, AlunoModel e RegistroDiarioModel mapeiam novos campos', () {
    final escola = EscolaModel.fromMap(<String, dynamic>{
      'papel': 'coordenador',
      'escolas': <String, dynamic>{
        'id': 'esc-1',
        'nome': 'E.M. Paulo Freire',
        'codigo_convite': 'PEI-AB12',
      },
    });
    expect(escola.id, 'esc-1');
    expect(escola.nome, 'E.M. Paulo Freire');
    expect(escola.codigoConvite, 'PEI-AB12');
    expect(escola.papelUsuario, 'coordenador');

    final aluno = AlunoModel.fromMap(<String, dynamic>{
      'id': 'a1',
      'professor_id': 'p1',
      'escola_id': 'esc-1',
      'nome': 'Lucas M.',
      'turma': '4º Ano B',
      'criado_em': '2026-11-20T12:00:00Z',
    });
    expect(aluno.escolaId, 'esc-1');

    final registro = RegistroDiarioModel.fromMap(<String, dynamic>{
      'id': 'r1',
      'aluno_id': 'a1',
      'professor_id': 'p1',
      'autor_email': 'prof@escola.edu.br',
      'data_registro': '2026-11-20',
      'categoria': 'Avanço',
      'descricao': 'Ótima participação.',
      'criado_em': '2026-11-20T12:00:00Z',
    });
    expect(registro.autorEmail, 'prof@escola.edu.br');
  });
}

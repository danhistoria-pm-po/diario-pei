import 'package:diario_pei/app.dart';
import 'package:diario_pei/core/utils/export_helper.dart';
import 'package:diario_pei/core/utils/pei_summary_formatter.dart';
import 'package:diario_pei/features/pei/data/models/aluno_model.dart';
import 'package:diario_pei/features/pei/data/models/escola_model.dart';
import 'package:diario_pei/features/pei/data/models/membro_escola_model.dart';
import 'package:diario_pei/features/pei/data/models/registro_diario_model.dart';
import 'package:diario_pei/features/pei/domain/entities/aluno.dart';
import 'package:diario_pei/features/pei/domain/entities/meta_pei.dart';
import 'package:diario_pei/features/pei/domain/entities/registro_diario.dart';
import 'package:diario_pei/features/pei/presentation/controllers/prontuario_controller.dart';
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

    expect(resumo, contains('=== RESUMO DO DIÁRIO PEI ==='));
    expect(resumo, isNot(contains('Aluno: Lucas Mendes')));
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
      'disciplina': 'Matemática',
      'data_registro': '2026-11-20',
      'categoria': 'Avanço',
      'descricao': 'Ótima participação.',
      'criado_em': '2026-11-20T12:00:00Z',
    });
    expect(registro.autorEmail, 'prof@escola.edu.br');
    expect(registro.disciplina, 'Matemática');
  });

  test('Filtros de disciplina e período e resumo com [Disciplina]', () {
    final base = DateTime(2026, 11, 23);
    final r1 = RegistroDiario(
      id: 'r1',
      alunoId: 'a1',
      professorId: 'p1',
      disciplina: 'Matemática',
      dataRegistro: DateTime(2026, 3, 15),
      categoria: 'Avanço',
      descricao: 'Resolveu adição com material concreto.',
      criadoEm: base,
    );
    final r2 = RegistroDiario(
      id: 'r2',
      alunoId: 'a1',
      professorId: 'p1',
      disciplina: 'Língua Portuguesa',
      dataRegistro: DateTime(2026, 11, 10),
      categoria: 'Acompanhamento',
      descricao: 'Leitura compartilhada com sucesso.',
      criadoEm: base,
    );

    final porDisciplina = ProntuarioController.filtrarRegistros(
      registros: <RegistroDiario>[r1, r2],
      disciplina: 'Matemática',
      periodo: FiltroPeriodoDiario.todoPeriodo,
      referencia: base,
    );
    expect(porDisciplina.length, 1);
    expect(porDisciplina.first.id, 'r1');

    final ultimos30 = ProntuarioController.filtrarRegistros(
      registros: <RegistroDiario>[r1, r2],
      disciplina: ProntuarioController.filtroDisciplinaTodas,
      periodo: FiltroPeriodoDiario.ultimos30Dias,
      referencia: base,
    );
    expect(ultimos30.length, 1);
    expect(ultimos30.first.id, 'r2');

    final primeiroBim = ProntuarioController.filtrarRegistros(
      registros: <RegistroDiario>[r1, r2],
      disciplina: ProntuarioController.filtroDisciplinaTodas,
      periodo: FiltroPeriodoDiario.primeiroBimestre,
      referencia: base,
    );
    expect(primeiroBim.length, 1);
    expect(primeiroBim.first.id, 'r1');

    final resumo = PeiSummaryFormatter.buildSummary(
      aluno: Aluno(
        id: 'a1',
        professorId: 'p1',
        nome: 'Ana C.',
        turma: '5º Ano A',
        criadoEm: base,
      ),
      metas: const <MetaPei>[],
      registros: <RegistroDiario>[r1],
    );
    expect(resumo, contains('15/03/2026 [Matemática] [Avanço]'));

    final terceiroTrim = ProntuarioController.filtrarRegistros(
      registros: <RegistroDiario>[r1, r2],
      disciplina: ProntuarioController.filtroDisciplinaTodas,
      periodo: FiltroPeriodoDiario.terceiroTrimestre,
      referencia: base,
    );
    expect(terceiroTrim.length, 1);
    expect(terceiroTrim.first.id, 'r2');

    final membro = MembroEscolaModel.fromMap(<String, dynamic>{
      'id': 'm1',
      'escola_id': 'esc-1',
      'user_id': 'u1',
      'user_email': 'coord@escola.edu.br',
      'papel': 'coordenador',
      'created_at': '2026-11-20T12:00:00Z',
    });
    expect(membro.isCoordenador, isTrue);
    expect(membro.email, 'coord@escola.edu.br');
  });
}

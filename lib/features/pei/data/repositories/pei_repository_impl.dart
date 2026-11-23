import '../../domain/entities/aluno.dart';
import '../../domain/entities/escola.dart';
import '../../domain/entities/membro_escola.dart';
import '../../domain/entities/meta_pei.dart';
import '../../domain/entities/registro_diario.dart';
import '../../domain/repositories/pei_repository.dart';
import '../datasources/pei_supabase_datasource.dart';

class PeiRepositoryImpl implements PeiRepository {
  const PeiRepositoryImpl(this._datasource);

  final PeiSupabaseDatasource _datasource;

  @override
  Future<Escola?> obterEscolaAtual() {
    return _datasource.obterEscolaAtual();
  }

  @override
  Future<Escola> criarEscola(String nome) {
    return _datasource.criarEscola(nome);
  }

  @override
  Future<Escola> entrarNaEscola(String codigoConvite) {
    return _datasource.entrarNaEscola(codigoConvite);
  }

  @override
  Future<void> atualizarNomeEscola(String escolaId, String novoNome) {
    return _datasource.atualizarNomeEscola(escolaId, novoNome);
  }

  @override
  Future<List<MembroEscola>> listarMembrosEscola(String escolaId) {
    return _datasource.listarMembrosEscola(escolaId);
  }

  @override
  Future<void> removerMembroEscola(String membroId) {
    return _datasource.removerMembroEscola(membroId);
  }

  @override
  Future<List<Aluno>> listarAlunos({String? busca}) {
    return _datasource.listarAlunos(busca: busca);
  }

  @override
  Future<Aluno> criarAluno({
    required String nome,
    required String turma,
    String? escolaId,
    String? diagnostico,
    String? observacoes,
  }) {
    return _datasource.criarAluno(
      nome: nome,
      turma: turma,
      escolaId: escolaId,
      diagnostico: diagnostico,
      observacoes: observacoes,
    );
  }

  @override
  Future<void> excluirAluno(String alunoId) {
    return _datasource.excluirAluno(alunoId);
  }

  @override
  Future<List<MetaPei>> listarMetas(String alunoId) {
    return _datasource.listarMetas(alunoId);
  }

  @override
  Future<MetaPei> criarMeta({
    required String alunoId,
    required String area,
    required String titulo,
    String? descricao,
    StatusMetaPei status = StatusMetaPei.pendente,
    DateTime? prazo,
  }) {
    return _datasource.criarMeta(
      alunoId: alunoId,
      area: area,
      titulo: titulo,
      descricao: descricao,
      status: status,
      prazo: prazo,
    );
  }

  @override
  Future<MetaPei> atualizarStatusMeta({
    required String metaId,
    required StatusMetaPei status,
  }) {
    return _datasource.atualizarStatusMeta(metaId: metaId, status: status);
  }

  @override
  Future<void> excluirMeta(String metaId) {
    return _datasource.excluirMeta(metaId);
  }

  @override
  Future<List<RegistroDiario>> listarRegistros(String alunoId) {
    return _datasource.listarRegistros(alunoId);
  }

  @override
  Future<RegistroDiario> criarRegistro({
    required String alunoId,
    required DateTime dataRegistro,
    required String categoria,
    required String descricao,
    String? disciplina,
  }) {
    return _datasource.criarRegistro(
      alunoId: alunoId,
      dataRegistro: dataRegistro,
      categoria: categoria,
      descricao: descricao,
      disciplina: disciplina,
    );
  }

  @override
  Future<void> excluirRegistro(String registroId) {
    return _datasource.excluirRegistro(registroId);
  }
}

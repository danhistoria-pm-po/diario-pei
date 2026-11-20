import '../entities/aluno.dart';
import '../entities/meta_pei.dart';
import '../entities/registro_diario.dart';

abstract class PeiRepository {
  Future<List<Aluno>> listarAlunos({String? busca});

  Future<Aluno> criarAluno({
    required String nome,
    required String turma,
    String? diagnostico,
    String? observacoes,
  });

  Future<void> excluirAluno(String alunoId);

  Future<List<MetaPei>> listarMetas(String alunoId);

  Future<MetaPei> criarMeta({
    required String alunoId,
    required String area,
    required String titulo,
    String? descricao,
    StatusMetaPei status = StatusMetaPei.pendente,
    DateTime? prazo,
  });

  Future<MetaPei> atualizarStatusMeta({
    required String metaId,
    required StatusMetaPei status,
  });

  Future<void> excluirMeta(String metaId);

  Future<List<RegistroDiario>> listarRegistros(String alunoId);

  Future<RegistroDiario> criarRegistro({
    required String alunoId,
    required DateTime dataRegistro,
    required String categoria,
    required String descricao,
  });

  Future<void> excluirRegistro(String registroId);
}

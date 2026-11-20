import 'package:flutter/foundation.dart';

import '../../domain/entities/aluno.dart';
import '../../domain/repositories/pei_repository.dart';

class AlunosController extends ChangeNotifier {
  AlunosController(this._repository);

  final PeiRepository _repository;

  List<Aluno> _alunos = const <Aluno>[];
  String _termoBusca = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Aluno> get alunos {
    final query = _termoBusca.trim().toLowerCase();
    if (query.isEmpty) {
      return List<Aluno>.unmodifiable(_alunos);
    }
    return List<Aluno>.unmodifiable(
      _alunos.where(
        (aluno) =>
            aluno.nome.toLowerCase().contains(query) ||
            aluno.turma.toLowerCase().contains(query) ||
            (aluno.diagnostico?.toLowerCase().contains(query) ?? false),
      ),
    );
  }

  String get termoBusca => _termoBusca;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void atualizarBusca(String termo) {
    _termoBusca = termo;
    notifyListeners();
  }

  Future<void> carregarAlunos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alunos = await _repository.listarAlunos();
    } catch (e) {
      _errorMessage = 'Erro ao carregar alunos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Aluno?> criarAluno({
    required String nome,
    required String turma,
    String? diagnostico,
    String? observacoes,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final novo = await _repository.criarAluno(
        nome: nome,
        turma: turma,
        diagnostico: diagnostico,
        observacoes: observacoes,
      );
      _alunos = <Aluno>[..._alunos, novo]
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return novo;
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar aluno: $e';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> excluirAluno(String alunoId) async {
    _errorMessage = null;
    try {
      await _repository.excluirAluno(alunoId);
      _alunos = _alunos.where((a) => a.id != alunoId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir aluno: $e';
      notifyListeners();
      return false;
    }
  }
}

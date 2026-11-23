import 'package:flutter/foundation.dart';

import '../../domain/entities/escola.dart';
import '../../domain/entities/membro_escola.dart';
import '../../domain/repositories/pei_repository.dart';

class EscolaController extends ChangeNotifier {
  EscolaController(this._repository);

  final PeiRepository _repository;

  Escola? _escolaAtual;
  List<MembroEscola> _membros = const <MembroEscola>[];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingMembros = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  Escola? get escolaAtual => _escolaAtual;
  List<MembroEscola> get membros => List<MembroEscola>.unmodifiable(_membros);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingMembros => _isLoadingMembros;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  void limpar() {
    _escolaAtual = null;
    _membros = const <MembroEscola>[];
    _isLoading = false;
    _isSubmitting = false;
    _isLoadingMembros = false;
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> carregarEscolaAtual() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _escolaAtual = await _repository.obterEscolaAtual();
      _hasLoaded = true;
    } catch (e) {
      _errorMessage = 'Erro ao verificar vínculo escolar: $e';
      _hasLoaded = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarEscola(String nome) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _escolaAtual = await _repository.criarEscola(nome);
      _hasLoaded = true;
      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível criar a escola: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> entrarNaEscola(String codigoConvite) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _escolaAtual = await _repository.entrarNaEscola(codigoConvite);
      _hasLoaded = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarNomeEscola(String escolaId, String novoNome) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nomeLimpo = novoNome.trim();
      await _repository.atualizarNomeEscola(escolaId, nomeLimpo);
      if (_escolaAtual != null && _escolaAtual!.id == escolaId) {
        _escolaAtual = _escolaAtual!.copyWith(nome: nomeLimpo);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível atualizar o nome da escola: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> carregarMembros() async {
    final escolaId = _escolaAtual?.id;
    if (escolaId == null) return;

    _isLoadingMembros = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _membros = await _repository.listarMembrosEscola(escolaId);
    } catch (e) {
      _errorMessage = 'Erro ao carregar equipe da escola: $e';
    } finally {
      _isLoadingMembros = false;
      notifyListeners();
    }
  }

  Future<bool> removerMembro(String membroId) async {
    _errorMessage = null;
    try {
      await _repository.removerMembroEscola(membroId);
      _membros = _membros.where((m) => m.id != membroId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível remover o membro: $e';
      notifyListeners();
      return false;
    }
  }
}

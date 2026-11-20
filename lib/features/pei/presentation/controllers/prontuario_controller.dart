import 'package:flutter/foundation.dart';

import '../../../../core/utils/pei_summary_formatter.dart';
import '../../domain/entities/aluno.dart';
import '../../domain/entities/meta_pei.dart';
import '../../domain/entities/registro_diario.dart';
import '../../domain/repositories/pei_repository.dart';

class ProntuarioController extends ChangeNotifier {
  ProntuarioController({
    required this.repository,
    required this.aluno,
  });

  final PeiRepository repository;
  final Aluno aluno;

  List<MetaPei> _metas = const <MetaPei>[];
  List<RegistroDiario> _registros = const <RegistroDiario>[];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<MetaPei> get metas => List<MetaPei>.unmodifiable(_metas);
  List<RegistroDiario> get registros =>
      List<RegistroDiario>.unmodifiable(_registros);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> carregarProntuario() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        repository.listarMetas(aluno.id),
        repository.listarRegistros(aluno.id),
      ]);
      _metas = results[0] as List<MetaPei>;
      _registros = results[1] as List<RegistroDiario>;
    } catch (e) {
      _errorMessage = 'Erro ao carregar prontuário: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarMeta({
    required String area,
    required String titulo,
    String? descricao,
    StatusMetaPei status = StatusMetaPei.pendente,
    DateTime? prazo,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final novaMeta = await repository.criarMeta(
        alunoId: aluno.id,
        area: area,
        titulo: titulo,
        descricao: descricao,
        status: status,
        prazo: prazo,
      );
      _metas = <MetaPei>[novaMeta, ..._metas];
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao criar meta: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarStatusMeta({
    required String metaId,
    required StatusMetaPei status,
  }) async {
    _errorMessage = null;
    try {
      final atualizada = await repository.atualizarStatusMeta(
        metaId: metaId,
        status: status,
      );
      _metas = _metas
          .map((meta) => meta.id == metaId ? atualizada : meta)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar status da meta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirMeta(String metaId) async {
    _errorMessage = null;
    try {
      await repository.excluirMeta(metaId);
      _metas = _metas.where((meta) => meta.id != metaId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir meta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> criarRegistro({
    required DateTime dataRegistro,
    required String categoria,
    required String descricao,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final novoRegistro = await repository.criarRegistro(
        alunoId: aluno.id,
        dataRegistro: dataRegistro,
        categoria: categoria,
        descricao: descricao,
      );
      _registros = <RegistroDiario>[novoRegistro, ..._registros]
        ..sort((a, b) {
          final byDate = b.dataRegistro.compareTo(a.dataRegistro);
          if (byDate != 0) return byDate;
          return b.criadoEm.compareTo(a.criadoEm);
        });
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao salvar registro no diário: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> excluirRegistro(String registroId) async {
    _errorMessage = null;
    try {
      await repository.excluirRegistro(registroId);
      _registros = _registros
          .where((registro) => registro.id != registroId)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir registro: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> copiarResumo() async {
    await PeiSummaryFormatter.copySummaryToClipboard(
      aluno: aluno,
      metas: _metas,
      registros: _registros,
    );
  }
}

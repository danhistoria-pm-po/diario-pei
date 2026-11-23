import 'package:flutter/foundation.dart';

import '../../../../core/utils/pei_summary_formatter.dart';
import '../../domain/entities/aluno.dart';
import '../../domain/entities/meta_pei.dart';
import '../../domain/entities/registro_diario.dart';
import '../../domain/repositories/pei_repository.dart';

enum FiltroPeriodoDiario {
  todoPeriodo('Todo o período'),
  ultimos30Dias('Últimos 30 dias'),
  primeiroBimestre('1º Bimestre (Jan–Abr)'),
  segundoBimestre('2º Bimestre (Mai–Jul)'),
  terceiroBimestre('3º Bimestre (Ago–Set)'),
  quartoBimestre('4º Bimestre (Out–Dez)'),
  primeiroTrimestre('1º Trimestre (Jan–Abr)'),
  segundoTrimestre('2º Trimestre (Mai–Ago)'),
  terceiroTrimestre('3º Trimestre (Set–Dez)');

  const FiltroPeriodoDiario(this.label);

  final String label;
}

class ProntuarioController extends ChangeNotifier {
  ProntuarioController({
    required this.repository,
    required this.aluno,
  });

  static const String filtroDisciplinaTodas = 'Todas';

  final PeiRepository repository;
  final Aluno aluno;

  List<MetaPei> _metas = const <MetaPei>[];
  List<RegistroDiario> _registros = const <RegistroDiario>[];
  String _filtroDisciplina = filtroDisciplinaTodas;
  FiltroPeriodoDiario _filtroPeriodo = FiltroPeriodoDiario.todoPeriodo;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<MetaPei> get metas => List<MetaPei>.unmodifiable(_metas);
  List<RegistroDiario> get registros =>
      List<RegistroDiario>.unmodifiable(_registros);
  List<RegistroDiario> get registrosFiltrados =>
      List<RegistroDiario>.unmodifiable(
        filtrarRegistros(
          registros: _registros,
          disciplina: _filtroDisciplina,
          periodo: _filtroPeriodo,
        ),
      );
  String get filtroDisciplina => _filtroDisciplina;
  FiltroPeriodoDiario get filtroPeriodo => _filtroPeriodo;
  bool get temFiltroAtivo =>
      _filtroDisciplina != filtroDisciplinaTodas ||
      _filtroPeriodo != FiltroPeriodoDiario.todoPeriodo;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  static List<RegistroDiario> filtrarRegistros({
    required List<RegistroDiario> registros,
    required String disciplina,
    required FiltroPeriodoDiario periodo,
    DateTime? referencia,
  }) {
    final agora = referencia ?? DateTime.now();
    final limite30Dias = DateTime(
      agora.year,
      agora.month,
      agora.day,
    ).subtract(const Duration(days: 30));

    return registros.where((registro) {
      if (disciplina != filtroDisciplinaTodas) {
        final discRegistro = registro.disciplina?.trim();
        if (discRegistro != disciplina) {
          return false;
        }
      }

      final data = registro.dataRegistro;
      return switch (periodo) {
        FiltroPeriodoDiario.todoPeriodo => true,
        FiltroPeriodoDiario.ultimos30Dias => !data.isBefore(limite30Dias),
        FiltroPeriodoDiario.primeiroBimestre =>
          data.month >= 1 && data.month <= 4,
        FiltroPeriodoDiario.segundoBimestre =>
          data.month >= 5 && data.month <= 7,
        FiltroPeriodoDiario.terceiroBimestre =>
          data.month >= 8 && data.month <= 9,
        FiltroPeriodoDiario.quartoBimestre =>
          data.month >= 10 && data.month <= 12,
        FiltroPeriodoDiario.primeiroTrimestre =>
          data.month >= 1 && data.month <= 4,
        FiltroPeriodoDiario.segundoTrimestre =>
          data.month >= 5 && data.month <= 8,
        FiltroPeriodoDiario.terceiroTrimestre =>
          data.month >= 9 && data.month <= 12,
      };
    }).toList();
  }

  void setFiltroDisciplina(String disciplina) {
    if (_filtroDisciplina == disciplina) return;
    _filtroDisciplina = disciplina;
    notifyListeners();
  }

  void setFiltroPeriodo(FiltroPeriodoDiario periodo) {
    if (_filtroPeriodo == periodo) return;
    _filtroPeriodo = periodo;
    notifyListeners();
  }

  void limparFiltros() {
    if (!temFiltroAtivo) return;
    _filtroDisciplina = filtroDisciplinaTodas;
    _filtroPeriodo = FiltroPeriodoDiario.todoPeriodo;
    notifyListeners();
  }

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
    String? disciplina,
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
        disciplina: disciplina,
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

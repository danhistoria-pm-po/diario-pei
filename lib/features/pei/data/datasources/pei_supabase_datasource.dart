import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/meta_pei.dart';
import '../models/aluno_model.dart';
import '../models/escola_model.dart';
import '../models/meta_pei_model.dart';
import '../models/registro_diario_model.dart';

class PeiSupabaseDatasource {
  const PeiSupabaseDatasource(this._client);

  final SupabaseClient _client;

  static const String _escolasTable = 'escolas';
  static const String _membrosEscolaTable = 'membros_escola';
  static const String _alunosTable = 'alunos';
  static const String _metasTable = 'metas_pei';
  static const String _registrosTable = 'registros_diario';
  static const String _codigoChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('Sessão expirada. Faça login novamente.');
    }
    return userId;
  }

  String _gerarCodigoConvite() {
    final random = Random.secure();
    final sufixo = List<String>.generate(
      4,
      (_) => _codigoChars[random.nextInt(_codigoChars.length)],
    ).join();
    return 'PEI-$sufixo';
  }

  Future<EscolaModel?> obterEscolaAtual() async {
    final userId = _requireUserId();
    final row = await _client
        .from(_membrosEscolaTable)
        .select('papel, escolas(id, nome, codigo_convite)')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return EscolaModel.fromMap(Map<String, dynamic>.from(row));
  }

  Future<EscolaModel> criarEscola(String nome) async {
    final userId = _requireUserId();
    final nomeLimpo = nome.trim();
    final codigoConvite = _gerarCodigoConvite();

    final escolaRow = await _client
        .from(_escolasTable)
        .insert(<String, dynamic>{
          'nome': nomeLimpo,
          'codigo_convite': codigoConvite,
        })
        .select('id, nome, codigo_convite')
        .single();

    final escolaId = escolaRow['id'] as String;

    await _client.from(_membrosEscolaTable).insert(<String, dynamic>{
      'escola_id': escolaId,
      'user_id': userId,
      'papel': 'coordenador',
    });

    return EscolaModel(
      id: escolaId,
      nome: escolaRow['nome'] as String,
      codigoConvite: escolaRow['codigo_convite'] as String,
      papelUsuario: 'coordenador',
    );
  }

  Future<EscolaModel> entrarNaEscola(String codigoConvite) async {
    final userId = _requireUserId();
    final codigoNormalizado = codigoConvite.trim().toUpperCase();

    final escolaRow = await _client
        .from(_escolasTable)
        .select('id, nome, codigo_convite')
        .eq('codigo_convite', codigoNormalizado)
        .maybeSingle();

    if (escolaRow == null) {
      throw Exception(
        'Nenhuma escola encontrada com o código "$codigoNormalizado".',
      );
    }

    final escolaId = escolaRow['id'] as String;

    await _client.from(_membrosEscolaTable).insert(<String, dynamic>{
      'escola_id': escolaId,
      'user_id': userId,
      'papel': 'professor',
    });

    return EscolaModel(
      id: escolaId,
      nome: escolaRow['nome'] as String,
      codigoConvite: escolaRow['codigo_convite'] as String,
      papelUsuario: 'professor',
    );
  }

  Future<void> atualizarNomeEscola(String escolaId, String novoNome) async {
    _requireUserId();
    await _client
        .from(_escolasTable)
        .update(<String, dynamic>{'nome': novoNome.trim()})
        .eq('id', escolaId);
  }

  Future<List<AlunoModel>> listarAlunos({String? busca}) async {
    final termo = busca?.trim();
    final List<dynamic> rows;

    if (termo != null && termo.isNotEmpty) {
      rows = await _client
          .from(_alunosTable)
          .select()
          .or('nome.ilike.%$termo%,turma.ilike.%$termo%')
          .order('nome', ascending: true);
    } else {
      rows = await _client
          .from(_alunosTable)
          .select()
          .order('nome', ascending: true);
    }

    return rows
        .map((row) => AlunoModel.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<AlunoModel> criarAluno({
    required String nome,
    required String turma,
    String? escolaId,
    String? diagnostico,
    String? observacoes,
  }) async {
    final userId = _requireUserId();
    final payload = <String, dynamic>{
      'professor_id': userId,
      if (escolaId != null && escolaId.isNotEmpty) 'escola_id': escolaId,
      'nome': nome.trim(),
      'turma': turma.trim(),
      'diagnostico': _nullIfBlank(diagnostico),
      'observacoes': _nullIfBlank(observacoes),
    };

    final row = await _client
        .from(_alunosTable)
        .insert(payload)
        .select()
        .single();

    return AlunoModel.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> excluirAluno(String alunoId) async {
    await _client.from(_alunosTable).delete().eq('id', alunoId);
  }

  Future<List<MetaPeiModel>> listarMetas(String alunoId) async {
    final rows = await _client
        .from(_metasTable)
        .select()
        .eq('aluno_id', alunoId)
        .order('criado_em', ascending: false);

    return (rows as List<dynamic>)
        .map(
          (row) => MetaPeiModel.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<MetaPeiModel> criarMeta({
    required String alunoId,
    required String area,
    required String titulo,
    String? descricao,
    StatusMetaPei status = StatusMetaPei.pendente,
    DateTime? prazo,
  }) async {
    final userId = _requireUserId();
    final payload = <String, dynamic>{
      'aluno_id': alunoId,
      'professor_id': userId,
      'area': area.trim(),
      'titulo': titulo.trim(),
      'descricao': _nullIfBlank(descricao),
      'status': status.value,
      'prazo': prazo != null ? MetaPeiModel.formatDateOnly(prazo) : null,
    };

    final row = await _client
        .from(_metasTable)
        .insert(payload)
        .select()
        .single();

    return MetaPeiModel.fromMap(Map<String, dynamic>.from(row));
  }

  Future<MetaPeiModel> atualizarStatusMeta({
    required String metaId,
    required StatusMetaPei status,
  }) async {
    final row = await _client
        .from(_metasTable)
        .update(<String, dynamic>{'status': status.value})
        .eq('id', metaId)
        .select()
        .single();

    return MetaPeiModel.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> excluirMeta(String metaId) async {
    await _client.from(_metasTable).delete().eq('id', metaId);
  }

  Future<List<RegistroDiarioModel>> listarRegistros(String alunoId) async {
    final rows = await _client
        .from(_registrosTable)
        .select()
        .eq('aluno_id', alunoId)
        .order('data_registro', ascending: false)
        .order('criado_em', ascending: false);

    return (rows as List<dynamic>)
        .map(
          (row) => RegistroDiarioModel.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<RegistroDiarioModel> criarRegistro({
    required String alunoId,
    required DateTime dataRegistro,
    required String categoria,
    required String descricao,
  }) async {
    final userId = _requireUserId();
    final autorEmail = _client.auth.currentUser?.email;
    final payload = <String, dynamic>{
      'aluno_id': alunoId,
      'professor_id': userId,
      'autor_email': autorEmail,
      'data_registro': MetaPeiModel.formatDateOnly(dataRegistro),
      'categoria': categoria.trim(),
      'descricao': descricao.trim(),
    };

    final row = await _client
        .from(_registrosTable)
        .insert(payload)
        .select()
        .single();

    return RegistroDiarioModel.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> excluirRegistro(String registroId) async {
    await _client.from(_registrosTable).delete().eq('id', registroId);
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

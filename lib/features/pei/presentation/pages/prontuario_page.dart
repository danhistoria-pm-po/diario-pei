import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/export_helper.dart';
import '../../../../core/utils/pei_summary_formatter.dart';
import '../../domain/entities/aluno.dart';
import '../../domain/entities/meta_pei.dart';
import '../../domain/repositories/pei_repository.dart';
import '../controllers/prontuario_controller.dart';
import '../widgets/meta_form_dialog.dart';
import '../widgets/meta_pei_card.dart';
import '../widgets/registro_diario_tile.dart';
import '../widgets/registro_form_dialog.dart';

class ProntuarioPage extends StatefulWidget {
  const ProntuarioPage({
    super.key,
    required this.aluno,
    required this.repository,
  });

  final Aluno aluno;
  final PeiRepository repository;

  @override
  State<ProntuarioPage> createState() => _ProntuarioPageState();
}

class _ProntuarioPageState extends State<ProntuarioPage>
    with SingleTickerProviderStateMixin {
  late final ProntuarioController _controller;
  late final TabController _tabController;
  final TextEditingController _parecerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ProntuarioController(
      repository: widget.repository,
      aluno: widget.aluno,
    )..carregarProntuario();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _parecerController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copiarResumo() async {
    await _controller.copiarResumo();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resumo do PEI copiado para a área de transferência.'),
      ),
    );
  }

  void _importarResumoParaEditor() {
    final resumo = PeiSummaryFormatter.buildSummary(
      aluno: widget.aluno,
      metas: _controller.metas,
      registros: _controller.registros,
    );
    _parecerController.text = resumo;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resumo importado para o editor de parecer.'),
      ),
    );
  }

  Future<void> _copiarParecerAtual() async {
    final texto = _parecerController.text.trim();
    if (texto.isEmpty) {
      _avisarEditorVazio();
      return;
    }
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto do parecer copiado para a área de transferência.'),
      ),
    );
  }

  void _exportarDoc() {
    final texto = _parecerController.text.trim();
    if (texto.isEmpty) {
      _avisarEditorVazio();
      return;
    }
    ExportHelper.exportarDoc(
      nomeAluno: widget.aluno.nome,
      turma: widget.aluno.turma,
      conteudoTexto: texto,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Download iniciado: ${ExportHelper.sanitizarNomeArquivo(widget.aluno.nome)}',
        ),
      ),
    );
  }

  void _exportarPdf() {
    final texto = _parecerController.text.trim();
    if (texto.isEmpty) {
      _avisarEditorVazio();
      return;
    }
    ExportHelper.exportarPdf(
      nomeAluno: widget.aluno.nome,
      turma: widget.aluno.turma,
      conteudoTexto: texto,
    );
  }

  void _avisarEditorVazio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Importe o resumo ou escreva o parecer pedagógico antes de exportar.',
        ),
      ),
    );
  }

  Future<void> _novaMeta() async {
    final result = await showDialog<MetaFormResult>(
      context: context,
      builder: (_) => const MetaFormDialog(),
    );
    if (result == null) return;

    final ok = await _controller.criarMeta(
      area: result.area,
      titulo: result.titulo,
      descricao: result.descricao,
      status: result.status,
      prazo: result.prazo,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta adicionada ao PEI.')),
      );
    }
  }

  Future<void> _novoRegistro() async {
    final result = await showDialog<RegistroFormResult>(
      context: context,
      builder: (_) => const RegistroFormDialog(),
    );
    if (result == null) return;

    final ok = await _controller.criarRegistro(
      dataRegistro: result.dataRegistro,
      categoria: result.categoria,
      descricao: result.descricao,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo no diário de bordo.')),
      );
    }
  }

  Widget? _buildFab() {
    return switch (_tabController.index) {
      0 => FloatingActionButton.extended(
        onPressed: _novaMeta,
        icon: const Icon(Icons.add_task),
        label: const Text('Nova Meta'),
      ),
      1 => FloatingActionButton.extended(
        onPressed: _novoRegistro,
        icon: const Icon(Icons.edit_note),
        label: const Text('Novo Registro'),
      ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.aluno.nome),
            Text(
              'Turma: ${widget.aluno.turma}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: _copiarResumo,
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              label: const Text('Copiar Resumo'),
            ),
          ),
          IconButton(
            tooltip: 'Atualizar prontuário',
            onPressed: _controller.carregarProntuario,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.flag_outlined), text: 'Metas do PEI'),
            Tab(icon: Icon(Icons.history_edu_outlined), text: 'Diário de Bordo'),
            Tab(icon: Icon(Icons.assignment_outlined), text: 'Relatório / AEE'),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final metas = _controller.metas;
              final registros = _controller.registros;
              final atingidas = metas
                  .where((m) => m.status == StatusMetaPei.atingida)
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: <Widget>[
                                Chip(
                                  avatar: const Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Metas atingidas: $atingidas/${metas.length}',
                                  ),
                                ),
                                Chip(
                                  avatar: const Icon(
                                    Icons.menu_book_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Registros no diário: ${registros.length}',
                                  ),
                                ),
                                if (widget.aluno.diagnostico != null &&
                                    widget.aluno.diagnostico!.trim().isNotEmpty)
                                  Chip(
                                    avatar: const Icon(
                                      Icons.info_outline,
                                      size: 18,
                                    ),
                                    label: Text(widget.aluno.diagnostico!),
                                  ),
                              ],
                            ),
                            if (widget.aluno.observacoes != null &&
                                widget.aluno.observacoes!
                                    .trim()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.aluno.observacoes!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _controller.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: _controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            children: <Widget>[
                              _buildMetasTab(theme),
                              _buildDiarioTab(theme),
                              _buildRelatorioTab(theme),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMetasTab(ThemeData theme) {
    final metas = _controller.metas;
    if (metas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.flag_outlined,
                size: 52,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhuma meta cadastrada para este aluno.',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Clique em "Nova Meta" para definir os objetivos do PEI.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
      itemCount: metas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final meta = metas[index];
        return MetaPeiCard(
          meta: meta,
          onStatusChanged: (status) {
            _controller.atualizarStatusMeta(metaId: meta.id, status: status);
          },
          onDelete: () => _controller.excluirMeta(meta.id),
        );
      },
    );
  }

  Widget _buildDiarioTab(ThemeData theme) {
    final registros = _controller.registros;
    if (registros.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.history_edu_outlined,
                size: 52,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhum registro no diário de bordo.',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Registre acompanhamentos cronológicos, avanços e adaptações.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
      itemCount: registros.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final registro = registros[index];
        return RegistroDiarioTile(
          registro: registro,
          onDelete: () => _controller.excluirRegistro(registro.id),
        );
      },
    );
  }

  Widget _buildRelatorioTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Parecer Pedagógico / Relatório AEE',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Importe o resumo das metas e do diário ou redija o parecer completo para exportar em Word (.doc) ou PDF A4.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.tonalIcon(
                    onPressed: _importarResumoParaEditor,
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text('Importar Resumo'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _copiarParecerAtual,
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: const Text('Copiar Texto'),
                  ),
                  FilledButton.icon(
                    onPressed: _exportarDoc,
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Baixar .DOC'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _exportarPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('PDF / Imprimir'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _parecerController,
                minLines: 12,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText:
                      'Clique em "Importar Resumo" ou escreva aqui o parecer pedagógico / relatório de AEE...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

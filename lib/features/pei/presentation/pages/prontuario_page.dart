import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/export_helper.dart';
import '../../../../core/utils/pei_summary_formatter.dart';
import '../../domain/entities/aluno.dart';
import '../../domain/entities/meta_pei.dart';
import '../../domain/entities/registro_diario.dart';
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
    this.nomeEscola,
  });

  final Aluno aluno;
  final PeiRepository repository;
  final String? nomeEscola;

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
      nomeEscola: widget.nomeEscola,
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
      nomeEscola: widget.nomeEscola,
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

  Future<void> _selecionarPeriodo() async {
    final atual = _controller.filtroPeriodo;
    final theme = Theme.of(context);

    Widget buildOpcao(FiltroPeriodoDiario periodo, {double leftPadding = 16}) {
      final selected = periodo == atual;
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.only(left: leftPadding, right: 16),
        selected: selected,
        title: Text(periodo.label),
        trailing: selected
            ? Icon(Icons.check, size: 18, color: theme.colorScheme.primary)
            : null,
        onTap: () => Navigator.of(context).pop(periodo),
      );
    }

    final selecionado = await showDialog<FiltroPeriodoDiario>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar período'),
        contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        content: SizedBox(
          width: 340,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildOpcao(FiltroPeriodoDiario.todoPeriodo),
                buildOpcao(FiltroPeriodoDiario.ultimos30Dias),
                const Divider(height: 1),
                ExpansionTile(
                  title: const Text('Trimestres'),
                  initiallyExpanded: false,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  children: <Widget>[
                    buildOpcao(
                      FiltroPeriodoDiario.primeiroTrimestre,
                      leftPadding: 28,
                    ),
                    buildOpcao(
                      FiltroPeriodoDiario.segundoTrimestre,
                      leftPadding: 28,
                    ),
                    buildOpcao(
                      FiltroPeriodoDiario.terceiroTrimestre,
                      leftPadding: 28,
                    ),
                  ],
                ),
                ExpansionTile(
                  title: const Text('Bimestres'),
                  initiallyExpanded: false,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  children: <Widget>[
                    buildOpcao(
                      FiltroPeriodoDiario.primeiroBimestre,
                      leftPadding: 28,
                    ),
                    buildOpcao(
                      FiltroPeriodoDiario.segundoBimestre,
                      leftPadding: 28,
                    ),
                    buildOpcao(
                      FiltroPeriodoDiario.terceiroBimestre,
                      leftPadding: 28,
                    ),
                    buildOpcao(
                      FiltroPeriodoDiario.quartoBimestre,
                      leftPadding: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

    if (selecionado != null) {
      _controller.setFiltroPeriodo(selecionado);
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
      disciplina: result.disciplina,
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
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final horizontalPadding = isMobile ? 12.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.aluno.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Turma: ${widget.aluno.turma}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (isMobile)
            IconButton(
              tooltip: 'Copiar Resumo',
              onPressed: _copiarResumo,
              icon: const Icon(Icons.copy_all_outlined),
            )
          else
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
          labelPadding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 4)
              : null,
          labelStyle: isMobile
              ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)
              : null,
          tabs: <Widget>[
            Tab(
              icon: const Icon(Icons.flag_outlined),
              child: Text(
                isMobile ? 'Metas' : 'Metas do PEI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Tab(
              icon: const Icon(Icons.history_edu_outlined),
              child: Text(
                isMobile ? 'Diário' : 'Diário de Bordo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Tab(
              icon: const Icon(Icons.assignment_outlined),
              child: Text(
                isMobile ? 'Relatório' : 'Relatório / AEE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isMobile ? 10 : 16,
                      horizontalPadding,
                      6,
                    ),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        initiallyExpanded: !isMobile,
                        dense: isMobile,
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          14,
                          0,
                          14,
                          12,
                        ),
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(
                          'Resumo • Metas: $atingidas/${metas.length} • Diário: ${registros.length}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: <Widget>[
                                Chip(
                                  visualDensity: VisualDensity.compact,
                                  avatar: const Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Metas atingidas: $atingidas/${metas.length}',
                                  ),
                                ),
                                Chip(
                                  visualDensity: VisualDensity.compact,
                                  avatar: const Icon(
                                    Icons.menu_book_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Registros no diário: ${registros.length}',
                                  ),
                                ),
                                if (widget.aluno.diagnostico != null &&
                                    widget.aluno.diagnostico!.trim().isNotEmpty)
                                  Chip(
                                    visualDensity: VisualDensity.compact,
                                    avatar: const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                    ),
                                    label: Text(widget.aluno.diagnostico!),
                                  ),
                              ],
                            ),
                          ),
                          if (widget.aluno.observacoes != null &&
                              widget.aluno.observacoes!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.aluno.observacoes!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
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
                              _buildMetasTab(theme, horizontalPadding),
                              _buildDiarioTab(theme, horizontalPadding),
                              _buildRelatorioTab(theme, horizontalPadding),
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

  Widget _buildMetasTab(ThemeData theme, double horizontalPadding) {
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Clique em "Nova Meta" para definir os objetivos do PEI.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        8,
        horizontalPadding,
        88,
      ),
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

  Widget _buildDiarioTab(ThemeData theme, double horizontalPadding) {
    final todosRegistros = _controller.registros;
    if (todosRegistros.isEmpty) {
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Registre acompanhamentos cronológicos, avanços e adaptações.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final filtrados = _controller.registrosFiltrados;
    final opcoesDisciplina = <String>[
      ProntuarioController.filtroDisciplinaTodas,
      ...kDisciplinasEscolares,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            6,
            horizontalPadding,
            4,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey<String>(
                            'disc-${_controller.filtroDisciplina}',
                          ),
                          initialValue: _controller.filtroDisciplina,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Disciplina',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          items: opcoesDisciplina
                              .map(
                                (disciplina) => DropdownMenuItem<String>(
                                  value: disciplina,
                                  child: Text(
                                    disciplina,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _controller.setFiltroDisciplina(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _selecionarPeriodo,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Período',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    _controller.filtroPeriodo.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Exibindo ${filtrados.length} de ${todosRegistros.length} registros',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (_controller.temFiltroAtivo)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: _controller.limparFiltros,
                          icon: const Icon(
                            Icons.filter_alt_off_outlined,
                            size: 16,
                          ),
                          label: const Text('Limpar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: filtrados.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.filter_list_off_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nenhum registro encontrado com os filtros atuais.',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _controller.limparFiltros,
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Limpar filtros'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    8,
                    horizontalPadding,
                    88,
                  ),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final registro = filtrados[index];
                    return RegistroDiarioTile(
                      registro: registro,
                      onDelete: () => _controller.excluirRegistro(registro.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRelatorioTab(ThemeData theme, double horizontalPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        8,
        horizontalPadding,
        32,
      ),
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

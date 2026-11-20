import 'package:flutter/material.dart';

import '../../domain/entities/aluno.dart';
import '../../domain/repositories/pei_repository.dart';
import '../controllers/alunos_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/aluno_form_dialog.dart';
import 'prontuario_page.dart';

class AlunosPage extends StatefulWidget {
  const AlunosPage({
    super.key,
    required this.repository,
    required this.authController,
  });

  final PeiRepository repository;
  final AuthController authController;

  @override
  State<AlunosPage> createState() => _AlunosPageState();
}

class _AlunosPageState extends State<AlunosPage> {
  late final AlunosController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AlunosController(widget.repository)..carregarAlunos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirCadastroAluno() async {
    final result = await showDialog<AlunoFormResult>(
      context: context,
      builder: (_) => const AlunoFormDialog(),
    );
    if (result == null) return;

    final criado = await _controller.criarAluno(
      nome: result.nome,
      turma: result.turma,
      diagnostico: result.diagnostico,
      observacoes: result.observacoes,
    );

    if (!mounted) return;
    if (criado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aluno "${criado.nome}" cadastrado.')),
      );
    }
  }

  Future<void> _confirmarExclusao(Aluno aluno) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir aluno'),
        content: Text(
          'Deseja excluir "${aluno.nome}"? Todas as metas e registros do diário vinculados serão removidos.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    final ok = await _controller.excluirAluno(aluno.id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aluno "${aluno.nome}" removido.')),
      );
    }
  }

  void _abrirProntuario(Aluno aluno) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProntuarioPage(
          aluno: aluno,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = widget.authController.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário PEI — Alunos'),
        actions: <Widget>[
          if (email != null && email.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Atualizar lista',
            onPressed: _controller.carregarAlunos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: widget.authController.signOut,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastroAluno,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Novo Aluno'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _searchController,
                  onChanged: _controller.atualizarBusca,
                  decoration: InputDecoration(
                    hintText: 'Buscar aluno por nome, turma ou diagnóstico...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        if (_controller.termoBusca.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          tooltip: 'Limpar busca',
                          onPressed: () {
                            _searchController.clear();
                            _controller.atualizarBusca('');
                          },
                          icon: const Icon(Icons.close),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      if (_controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final error = _controller.errorMessage;
                      final alunos = _controller.alunos;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                error,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Expanded(
                            child: alunos.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          Icons.school_outlined,
                                          size: 56,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _controller.termoBusca.isEmpty
                                              ? 'Nenhum aluno cadastrado ainda.'
                                              : 'Nenhum aluno encontrado para "${_controller.termoBusca}".',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Clique em "Novo Aluno" para iniciar um PEI.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: alunos.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final aluno = alunos[index];
                                      return Card(
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                          leading: CircleAvatar(
                                            backgroundColor: theme
                                                .colorScheme.primaryContainer,
                                            foregroundColor: theme
                                                .colorScheme.onPrimaryContainer,
                                            child: Text(
                                              aluno.nome.isNotEmpty
                                                  ? aluno.nome[0].toUpperCase()
                                                  : '?',
                                            ),
                                          ),
                                          title: Text(
                                            aluno.nome,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Turma: ${aluno.turma}'),
                                              if (aluno.diagnostico != null &&
                                                  aluno.diagnostico!
                                                      .trim()
                                                      .isNotEmpty)
                                                Text(
                                                  aluno.diagnostico!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              IconButton(
                                                tooltip: 'Excluir aluno',
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () =>
                                                    _confirmarExclusao(aluno),
                                              ),
                                              const Icon(Icons.chevron_right),
                                            ],
                                          ),
                                          onTap: () => _abrirProntuario(aluno),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

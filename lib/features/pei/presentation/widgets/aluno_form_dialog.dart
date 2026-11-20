import 'package:flutter/material.dart';

class AlunoFormResult {
  const AlunoFormResult({
    required this.nome,
    required this.turma,
    this.diagnostico,
    this.observacoes,
  });

  final String nome;
  final String turma;
  final String? diagnostico;
  final String? observacoes;
}

class AlunoFormDialog extends StatefulWidget {
  const AlunoFormDialog({super.key});

  @override
  State<AlunoFormDialog> createState() => _AlunoFormDialogState();
}

class _AlunoFormDialogState extends State<AlunoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _turmaController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _observacoesController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _turmaController.dispose();
    _diagnosticoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      AlunoFormResult(
        nome: _nomeController.text.trim(),
        turma: _turmaController.text.trim(),
        diagnostico: _diagnosticoController.text.trim(),
        observacoes: _observacoesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Aluno'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    hintText: 'Ex.: Lucas Mendes',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do aluno.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _turmaController,
                  decoration: const InputDecoration(
                    labelText: 'Turma / Ano *',
                    hintText: 'Ex.: 4º Ano B - Manhã',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a turma.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _diagnosticoController,
                  decoration: const InputDecoration(
                    labelText: 'Diagnóstico / Necessidade educacional',
                    hintText: 'Opcional (ex.: TEA, TDAH, Dislexia)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacoesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações iniciais',
                    hintText: 'Adaptações, interesses, apoios importantes...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

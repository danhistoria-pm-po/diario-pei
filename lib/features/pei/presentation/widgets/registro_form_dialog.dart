import 'package:flutter/material.dart';

import '../../../../core/utils/pei_summary_formatter.dart';

class RegistroFormResult {
  const RegistroFormResult({
    required this.dataRegistro,
    required this.categoria,
    required this.descricao,
  });

  final DateTime dataRegistro;
  final String categoria;
  final String descricao;
}

class RegistroFormDialog extends StatefulWidget {
  const RegistroFormDialog({super.key});

  @override
  State<RegistroFormDialog> createState() => _RegistroFormDialogState();
}

class _RegistroFormDialogState extends State<RegistroFormDialog> {
  static const List<String> _categorias = <String>[
    'Acompanhamento',
    'Avanço',
    'Adaptação',
    'Interação Social',
    'Família / Reunião',
    'Ocorrência',
  ];

  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();

  DateTime _dataRegistro = DateTime.now();
  String _categoria = _categorias.first;

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataRegistro,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _dataRegistro = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      RegistroFormResult(
        dataRegistro: _dataRegistro,
        categoria: _categoria,
        descricao: _descricaoController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Registro no Diário'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    'Data: ${PeiSummaryFormatter.formatDateBr(_dataRegistro)}',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Categoria'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _categorias
                      .map(
                        (cat) => ChoiceChip(
                          label: Text(cat),
                          selected: _categoria == cat,
                          onSelected: (_) => setState(() => _categoria = cat),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Relato pedagógico *',
                    hintText:
                        'Descreva a atividade, mediação realizada e resposta do aluno...',
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a descrição do registro.';
                    }
                    return null;
                  },
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
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}

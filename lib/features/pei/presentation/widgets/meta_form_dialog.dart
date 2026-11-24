import 'package:flutter/material.dart';

import '../../../../core/utils/pei_summary_formatter.dart';
import '../../domain/entities/meta_pei.dart';

class MetaFormResult {
  const MetaFormResult({
    required this.area,
    required this.titulo,
    this.descricao,
    required this.status,
    this.prazo,
  });

  final String area;
  final String titulo;
  final String? descricao;
  final StatusMetaPei status;
  final DateTime? prazo;
}

class MetaFormDialog extends StatefulWidget {
  const MetaFormDialog({super.key});

  @override
  State<MetaFormDialog> createState() => _MetaFormDialogState();
}

class _MetaFormDialogState extends State<MetaFormDialog> {
  static const List<String> _areasSugeridas = <String>[
    'Alfabetização e Leitura',
    'Raciocínio Lógico',
    'Comunicação',
    'Autonomia',
    'Socialização',
    'Motricidade',
  ];

  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController(text: 'Alfabetização e Leitura');
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  StatusMetaPei _status = StatusMetaPei.pendente;
  DateTime? _prazo;

  @override
  void dispose() {
    _areaController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarPrazo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _prazo ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _prazo = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      MetaFormResult(
        area: _areaController.text.trim(),
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        status: _status,
        prazo: _prazo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Meta do PEI'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Área pedagógica *',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a área da meta.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _areasSugeridas
                      .map(
                        (area) => ActionChip(
                          label: Text(area),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            _areaController.text = area;
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título da meta *',
                    hintText: 'Ex.: Ler frases curtas com apoio visual',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o título da meta.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Estratégias e critérios de avaliação',
                    hintText: 'Opcional',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                const Text('Status inicial'),
                const SizedBox(height: 6),
                SegmentedButton<StatusMetaPei>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    textStyle: WidgetStatePropertyAll<TextStyle>(
                      TextStyle(fontSize: 12),
                    ),
                  ),
                  segments: const <ButtonSegment<StatusMetaPei>>[
                    ButtonSegment<StatusMetaPei>(
                      value: StatusMetaPei.pendente,
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Pendente',
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                    ButtonSegment<StatusMetaPei>(
                      value: StatusMetaPei.emAndamento,
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Andamento',
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                    ButtonSegment<StatusMetaPei>(
                      value: StatusMetaPei.atingida,
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Atingida',
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                  selected: <StatusMetaPei>{_status},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      setState(() => _status = selection.first);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selecionarPrazo,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          _prazo == null
                              ? 'Definir prazo (opcional)'
                              : 'Prazo: ${PeiSummaryFormatter.formatDateBr(_prazo!)}',
                        ),
                      ),
                    ),
                    if (_prazo != null)
                      IconButton(
                        tooltip: 'Remover prazo',
                        onPressed: () => setState(() => _prazo = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
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
          child: const Text('Salvar Meta'),
        ),
      ],
    );
  }
}

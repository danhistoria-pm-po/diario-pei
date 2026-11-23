import 'package:flutter/material.dart';

import '../../../../core/utils/pei_summary_formatter.dart';
import '../../domain/entities/registro_diario.dart';

class RegistroDiarioTile extends StatelessWidget {
  const RegistroDiarioTile({
    super.key,
    required this.registro,
    required this.onDelete,
  });

  final RegistroDiario registro;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disciplina = registro.disciplina?.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            PeiSummaryFormatter.formatDateBr(
                              registro.dataRegistro,
                            ),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (disciplina != null && disciplina.isNotEmpty)
                        Chip(
                          avatar: Icon(
                            Icons.menu_book_outlined,
                            size: 15,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          label: Text(disciplina),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          labelStyle: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Chip(
                        label: Text(registro.categoria),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Excluir registro',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              registro.descricao,
              style: theme.textTheme.bodyMedium,
            ),
            if (registro.autorEmail != null &&
                registro.autorEmail!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Registrado por ${registro.autorEmail}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

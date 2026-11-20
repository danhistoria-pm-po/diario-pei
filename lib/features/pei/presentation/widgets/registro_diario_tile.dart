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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  PeiSummaryFormatter.formatDateBr(registro.dataRegistro),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(registro.categoria),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const Spacer(),
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
          ],
        ),
      ),
    );
  }
}

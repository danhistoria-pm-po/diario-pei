import 'package:flutter/material.dart';

import '../../../../core/utils/pei_summary_formatter.dart';
import '../../domain/entities/meta_pei.dart';

class MetaPeiCard extends StatelessWidget {
  const MetaPeiCard({
    super.key,
    required this.meta,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final MetaPei meta;
  final ValueChanged<StatusMetaPei> onStatusChanged;
  final VoidCallback onDelete;

  Color _statusColor(ColorScheme scheme, StatusMetaPei status) {
    return switch (status) {
      StatusMetaPei.pendente => scheme.outline,
      StatusMetaPei.emAndamento => scheme.primary,
      StatusMetaPei.atingida => const Color(0xFF2E7D32),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(theme.colorScheme, meta.status);

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
                      Chip(
                        label: Text(meta.area),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        backgroundColor:
                            theme.colorScheme.secondaryContainer,
                      ),
                      if (meta.prazo != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.event_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Prazo: ${PeiSummaryFormatter.formatDateBr(meta.prazo!)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Opções da meta',
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete_outline, size: 18),
                          SizedBox(width: 8),
                          Text('Excluir meta'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meta.titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (meta.descricao != null && meta.descricao!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                meta.descricao!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    meta.status.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SegmentedButton<StatusMetaPei>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const <ButtonSegment<StatusMetaPei>>[
                    ButtonSegment<StatusMetaPei>(
                      value: StatusMetaPei.pendente,
                      label: Text('Pendente'),
                    ),
                    ButtonSegment<StatusMetaPei>(
                      value: StatusMetaPei.emAndamento,
                      label: Text('Andamento'),
                    ),
                    ButtonSegment<StatusMetaPei>(
                      value: StatusMetaPei.atingida,
                      label: Text('Atingida'),
                    ),
                  ],
                  selected: <StatusMetaPei>{meta.status},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      onStatusChanged(selection.first);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

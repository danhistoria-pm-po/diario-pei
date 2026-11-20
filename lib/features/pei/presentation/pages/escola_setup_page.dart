import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/escola_controller.dart';

class EscolaSetupPage extends StatefulWidget {
  const EscolaSetupPage({
    super.key,
    required this.escolaController,
    required this.authController,
  });

  final EscolaController escolaController;
  final AuthController authController;

  @override
  State<EscolaSetupPage> createState() => _EscolaSetupPageState();
}

class _EscolaSetupPageState extends State<EscolaSetupPage> {
  final _criarFormKey = GlobalKey<FormState>();
  final _entrarFormKey = GlobalKey<FormState>();
  final _nomeEscolaController = TextEditingController();
  final _codigoConviteController = TextEditingController();

  @override
  void dispose() {
    _nomeEscolaController.dispose();
    _codigoConviteController.dispose();
    super.dispose();
  }

  Future<void> _criarEscola() async {
    if (!(_criarFormKey.currentState?.validate() ?? false)) return;
    await widget.escolaController.criarEscola(_nomeEscolaController.text);
  }

  Future<void> _entrarNaEscola() async {
    if (!(_entrarFormKey.currentState?.validate() ?? false)) return;
    await widget.escolaController.entrarNaEscola(
      _codigoConviteController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = widget.authController.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário PEI — Vincular Escola'),
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
            tooltip: 'Sair',
            onPressed: widget.authController.signOut,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListenableBuilder(
              listenable: widget.escolaController,
              builder: (context, _) {
                final isSubmitting = widget.escolaController.isSubmitting;
                final error = widget.escolaController.errorMessage;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Configure sua escola para começar',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crie um novo ambiente escolar como coordenador ou entre em uma escola existente usando o código de convite compartilhado pela equipe.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      const SizedBox(height: 16),
                    ],
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 640;
                        final criarCard = _buildCriarEscolaCard(
                          theme: theme,
                          isSubmitting: isSubmitting,
                        );
                        final entrarCard = _buildEntrarEscolaCard(
                          theme: theme,
                          isSubmitting: isSubmitting,
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child: criarCard),
                              const SizedBox(width: 16),
                              Expanded(child: entrarCard),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            criarCard,
                            const SizedBox(height: 16),
                            entrarCard,
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCriarEscolaCard({
    required ThemeData theme,
    required bool isSubmitting,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _criarFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.add_business_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Criar nova escola',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Gera um código de convite (ex.: PEI-AB12) para outros professores entrarem na mesma equipe.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeEscolaController,
                enabled: !isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Nome da escola *',
                  hintText: 'Ex.: E.M. Paulo Freire',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Informe o nome da escola (mín. 3 caracteres).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: isSubmitting ? null : _criarEscola,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.school_outlined, size: 18),
                label: const Text('Criar escola'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntrarEscolaCard({
    required ThemeData theme,
    required bool isSubmitting,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _entrarFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.group_add_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Entrar em uma escola',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Digite o código de convite fornecido pela coordenação da sua escola.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoConviteController,
                enabled: !isSubmitting,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código de convite *',
                  hintText: 'Ex.: PEI-A1B2',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o código de convite.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: isSubmitting ? null : _entrarNaEscola,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login, size: 18),
                label: const Text('Entrar na escola'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

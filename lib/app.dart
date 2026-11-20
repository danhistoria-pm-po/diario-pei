import 'package:flutter/material.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/pei/data/datasources/pei_supabase_datasource.dart';
import 'features/pei/data/repositories/pei_repository_impl.dart';
import 'features/pei/domain/repositories/pei_repository.dart';
import 'features/pei/presentation/controllers/auth_controller.dart';
import 'features/pei/presentation/controllers/escola_controller.dart';
import 'features/pei/presentation/pages/alunos_page.dart';
import 'features/pei/presentation/pages/escola_setup_page.dart';
import 'features/pei/presentation/pages/login_page.dart';

class DiarioPeiApp extends StatelessWidget {
  const DiarioPeiApp({
    super.key,
    required this.isSupabaseConfigured,
  });

  final bool isSupabaseConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diário PEI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: isSupabaseConfigured
          ? const _AuthGate()
          : const _MissingSupabaseConfigPage(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final AuthController _authController;
  late final PeiRepository _repository;
  late final EscolaController _escolaController;
  String? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    final client = SupabaseConfig.client;
    _authController = AuthController(client);
    _repository = PeiRepositoryImpl(PeiSupabaseDatasource(client));
    _escolaController = EscolaController(_repository);

    _authController.addListener(_syncEscolaWithAuth);
    _syncEscolaWithAuth();
  }

  void _syncEscolaWithAuth() {
    if (!_authController.isAuthenticated) {
      if (_lastLoadedUserId != null) {
        _lastLoadedUserId = null;
        _escolaController.limpar();
      }
      return;
    }

    final userId = _authController.currentUser?.id;
    if (userId != null && userId != _lastLoadedUserId) {
      _lastLoadedUserId = userId;
      _escolaController.carregarEscolaAtual();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_syncEscolaWithAuth);
    _escolaController.dispose();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        _authController,
        _escolaController,
      ]),
      builder: (context, _) {
        if (!_authController.isAuthenticated) {
          return LoginPage(authController: _authController);
        }

        if (!_escolaController.hasLoaded || _escolaController.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final escola = _escolaController.escolaAtual;
        if (escola == null) {
          return EscolaSetupPage(
            escolaController: _escolaController,
            authController: _authController,
          );
        }

        return AlunosPage(
          escola: escola,
          escolaController: _escolaController,
          repository: _repository,
          authController: _authController,
        );
      },
    );
  }
}

class _MissingSupabaseConfigPage extends StatelessWidget {
  const _MissingSupabaseConfigPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.settings_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Configuração do Supabase pendente',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Informe SUPABASE_URL e SUPABASE_ANON_KEY via --dart-define ao executar ou compilar o Diário PEI:',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const SelectableText(
                        'flutter run -d chrome \\\n'
                        '  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \\\n'
                        '  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

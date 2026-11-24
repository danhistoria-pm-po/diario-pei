import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _lgpdAceito = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isSignUpMode && !_lgpdAceito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'É obrigatório aceitar os Termos de Uso e Diretrizes da LGPD para criar conta.',
          ),
        ),
      );
      return;
    }

    if (_isSignUpMode) {
      await widget.authController.signUp(
        nome: _nomeController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await widget.authController.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  void _toggleMode() {
    widget.authController.clearMessages();
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _lgpdAceito = false;
    });
  }

  Future<void> _abrirTermoLgpd() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termo de Uso e Diretrizes da LGPD'),
        content: const SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Ao utilizar o Diário PEI, você concorda com as seguintes diretrizes de privacidade e proteção de dados educacionais:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Responsabilidade no tratamento de dados de menores (Art. 14 da LGPD): '
                  'O educador e a instituição de ensino são responsáveis pela coleta, registro e compartilhamento adequado das informações de estudantes, devendo atuar sempre no melhor interesse do aluno e em conformidade com as autorizações da escola e das famílias.',
                ),
                SizedBox(height: 10),
                Text(
                  '2. Minimização de dados pessoais: '
                  'Recomenda-se identificar o estudante utilizando apenas o primeiro nome + inicial do sobrenome (ou código de matrícula escolar), evitando expor dados pessoais desnecessários.',
                ),
                SizedBox(height: 10),
                Text(
                  '3. Foco estritamente pedagógico: '
                  'Os campos de adaptação, metas e diário de bordo devem priorizar estratégias pedagógicas, recursos de acessibilidade e avanços de aprendizagem — evite armazenar diagnósticos clínicos detalhados, laudos médicos ou códigos CID.',
                ),
                SizedBox(height: 10),
                Text(
                  '4. Sigilo e finalidade exclusiva: '
                  'As informações registradas são de uso sigiloso e exclusivo para fins pedagógicos e de acompanhamento escolar pela equipe autorizada da instituição.',
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
          FilledButton(
            onPressed: () {
              setState(() => _lgpdAceito = true);
              Navigator.of(context).pop();
            },
            child: const Text('Concordo e aceito'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
            child: ListenableBuilder(
              listenable: widget.authController,
              builder: (context, _) {
                final isLoading = widget.authController.isLoading;
                final error = widget.authController.errorMessage;
                final info = widget.authController.infoMessage;
                final canSubmit = !isLoading && (!_isSignUpMode || _lgpdAceito);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Icon(
                                Icons.menu_book_rounded,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Diário PEI',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Plano Educacional Individualizado e Diário de Bordo',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
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
                                const SizedBox(height: 14),
                              ],
                              if (info != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    info,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],
                              if (_isSignUpMode) ...[
                                TextFormField(
                                  controller: _nomeController,
                                  enabled: !isLoading,
                                  textCapitalization: TextCapitalization.words,
                                  autofillHints: const <String>[
                                    AutofillHints.name,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Nome completo',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (!_isSignUpMode) return null;
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.length < 3) {
                                      return 'Informe seu nome completo.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                              ],
                              TextFormField(
                                controller: _emailController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const <String>[
                                  AutofillHints.email,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'E-mail institucional',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty ||
                                      !trimmed.contains('@')) {
                                    return 'Informe um e-mail válido.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                obscureText: _obscurePassword,
                                autofillHints: const <String>[
                                  AutofillHints.password,
                                ],
                                onFieldSubmitted: (_) {
                                  if (canSubmit) _submit();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Mostrar senha'
                                        : 'Ocultar senha',
                                    onPressed: () {
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres.';
                                  }
                                  return null;
                                },
                              ),
                              if (_isSignUpMode) ...[
                                const SizedBox(height: 14),
                                CheckboxListTile(
                                  value: _lgpdAceito,
                                  onChanged: isLoading
                                      ? null
                                      : (checked) {
                                          setState(
                                            () =>
                                                _lgpdAceito = checked ?? false,
                                          );
                                        },
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    'Li e concordo com os Termos de Uso e Diretrizes da LGPD para tratamento de dados educacionais.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : _abrirTermoLgpd,
                                    icon: const Icon(
                                      Icons.privacy_tip_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Ler Termo LGPD'),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              FilledButton(
                                onPressed: canSubmit ? _submit : null,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isSignUpMode
                                            ? 'Criar conta'
                                            : 'Entrar',
                                      ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: isLoading ? null : _toggleMode,
                                child: Text(
                                  _isSignUpMode
                                      ? 'Já possui conta? Entrar'
                                      : 'Primeiro acesso? Criar conta',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Column(
                      children: <Widget>[
                        Text(
                          'Desenvolvido por Danny Bustamante',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'CNPJ: 68.929.253/0001-88',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      ),
    );
  }
}

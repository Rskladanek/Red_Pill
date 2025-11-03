import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _passRepeat = TextEditingController();

  bool _loading = false;
  String? _submitError;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _passRepeat.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Podaj email';
    if (!v.contains('@') || !v.contains('.')) return 'To nie wygląda jak email';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Min. 8 znaków.';
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Dodaj chociaż jedną DUŻĄ literę.';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Dodaj chociaż jedną cyfrę.';
    }
    return null;
  }

  String? _validatePasswordRepeat(String? value) {
    if (value != _pass.text) {
      return 'Hasła muszą być takie same.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() {
      _loading = true;
      _submitError = null;
    });

    try {
      await AuthService.register(_email.text.trim(), _pass.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _registerWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rejestracja przez Google: front gotowy, trzeba podpiąć backend/OAuth.'),
      ),
    );
    // Docelowo:
    // await AuthService.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'Dołącz do REDPILL',
                      style: s.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Zerwij z byciem NPC. Jedna apka, trzy filary, zero wymówek.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pass,
                      obscureText: true,
                      validator: _validatePassword,
                      decoration: const InputDecoration(
                        labelText: 'Hasło',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hasło: min. 8 znaków, 1 duża litera, 1 cyfra.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passRepeat,
                      obscureText: true,
                      validator: _validatePasswordRepeat,
                      decoration: const InputDecoration(
                        labelText: 'Powtórz hasło',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_submitError != null) ...[
                      Text(
                        _submitError!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Stwórz konto'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'albo',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _registerWithGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Zarejestruj przez Google'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      child: const Text('Mam już konto – zaloguj mnie'),
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


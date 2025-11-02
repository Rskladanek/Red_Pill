import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/dashboard_page.dart';
import 'models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(text: 't@t.pl'); // wygoda w dev
  final _pass = TextEditingController(text: '123456');
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final UserModel u = await AuthService.login(_email.text.trim(), _pass.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zalogowano: ${u.email}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Log in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Log in'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                  child: const Text('Create account'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


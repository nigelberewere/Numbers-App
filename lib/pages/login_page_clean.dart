import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_user.dart';

class CleanLoginPage extends StatefulWidget {
  const CleanLoginPage({super.key});

  @override
  State<CleanLoginPage> createState() => _CleanLoginPageState();
}

class _CleanLoginPageState extends State<CleanLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
  AuthUser? _user;

  AuthService get _auth => authService;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    AuthUser? user;
    if (_isLogin) {
      user = await _auth.signInWithEmail(email, password);
    } else {
      user = await _auth.signUpWithEmail(email, password);
    }
    setState(() {
      _user = user;
      _loading = false;
    });
    if (user != null) {
      _showSignedInDialog(user);
    } else {
      _showError('Sign in failed. Check credentials.');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    final user = await _auth.signInWithGoogle();
    setState(() {
      _user = user;
      _loading = false;
    });
    if (user != null) {
      _showSignedInDialog(user);
    } else {
      _showError('Google sign in cancelled or failed.');
    }
  }

  void _showSignedInDialog(AuthUser user) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signed in'),
        content: Text('Hello ${user.displayName ?? user.email ?? user.uid}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildGoogleButton(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onPressed: _loading ? null : _signInWithGoogle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('lib/assets/icon/google_logo.png', width: 20, height: 20),
          const SizedBox(width: 12),
          Text('Sign in with Google', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App logo + title
                    Row(
                      children: [
                        Image.asset('lib/assets/icon/logo.png', width: 56, height: 56),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Numbers', style: Theme.of(context).textTheme.headlineSmall),
                            Text('Manage your business data', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Login/Signup toggle
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isLogin = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLogin ? Theme.of(context).colorScheme.primary : Colors.transparent,
                              foregroundColor: _isLogin ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              elevation: 0,
                            ),
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isLogin = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isLogin ? Theme.of(context).colorScheme.primary : Colors.transparent,
                              foregroundColor: !_isLogin ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              elevation: 0,
                            ),
                            child: const Text('Sign up'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter email';
                              if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v)) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter password';
                              if (v.length < 6) return 'Password at least 6 chars';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(_isLogin ? 'Login' : 'Create account'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(children: [Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300])), const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or')), Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]))]),
                    const SizedBox(height: 12),

                    // Google button
                    _buildGoogleButton(context),

                    const SizedBox(height: 12),
                    Text('By continuing you agree to our Terms and Privacy Policy', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),

                    const SizedBox(height: 12),
                    if (_user != null)
                      Card(
                        margin: const EdgeInsets.only(top: 12),
                        child: ListTile(
                          leading: _user!.photoUrl != null ? CircleAvatar(backgroundImage: NetworkImage(_user!.photoUrl!)) : null,
                          title: Text(_user!.displayName ?? _user!.email ?? _user!.uid),
                          subtitle: Text(_user!.email ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () async {
                              await _auth.signOut();
                              setState(() => _user = null);
                            },
                          ),
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

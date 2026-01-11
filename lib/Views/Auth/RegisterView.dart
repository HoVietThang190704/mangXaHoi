import 'package:flutter/material.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/Service/AuthService.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirm = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    txtName.dispose();
    txtEmail.dispose();
    txtPassword.dispose();
    txtConfirm.dispose();
    super.dispose();
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    return raw.replaceFirst('Exception: ', '').trim();
  }

  Future<void> _register() async {
    if (_isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final name = txtName.text.trim();
    final email = txtEmail.text.trim();
    final password = txtPassword.text;
    final confirmPassword = txtConfirm.text;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword, 
        userName: name,
      );

      Utils.userName = result.user?.userName ?? name;

      if (!mounted) return;

      final message = (result.message.isNotEmpty)
          ? result.message
          : AppLocalizations.of(context)!.register_success;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      if (!mounted) return;

      final fallback = AppLocalizations.of(context)!.register_error;
      final message = _extractErrorMessage(error);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isNotEmpty ? message : fallback)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGradientButton(
    String text,
    VoidCallback? onTap, {
    bool isLoading = false,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: (enabled && !isLoading && onTap != null) ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(colors: [Color(0xFF3AA0FF), Color(0xFF1777F2)])
              : null,
          color: enabled ? null : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                t.name_main,
                style: const TextStyle(
                  color: Color(0xFF1877F2),
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: txtName,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              hintText: t.name_label,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? t.name_required : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: txtEmail,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email),
                              hintText: t.email_label,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return t.email_required;
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) return t.email_invalid;
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: txtPassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              hintText: t.hint_password,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return t.password_required;
                              if (v.length < 6) return t.password_too_short;
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: txtConfirm,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              hintText: t.confirm_password,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return t.confirm_password_required;
                              if (v != txtPassword.text) return t.password_mismatch;
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildGradientButton(
                            t.register,
                            _register,
                            isLoading: _isLoading,
                            enabled: !_isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  t.register_prompt,
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

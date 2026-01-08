import 'package:flutter/material.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/Service/AuthService.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
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
    if (_isLoading) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        email: txtEmail.text.trim(),
        password: txtPassword.text,
        userName: txtName.text.trim(),
      );

      Utils.userName = result.user?.userName ?? txtName.text.trim();

      if (!mounted) {
        return;
      }

      final message = (result.message.isNotEmpty)
          ? result.message
          : AppLocalizations.of(context)!.register_success;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      if (!mounted) {
        return;
      }
      final fallback = AppLocalizations.of(context)!.register_error;
      final message = _extractErrorMessage(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isNotEmpty ? message : fallback)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildGradientButton(String text, VoidCallback? onTap, {bool isLoading = false, bool enabled = true}) {
    return InkWell(
      onTap: (enabled && !isLoading && onTap != null) ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(colors: [Color(0xFF3AA0FF), Color(0xFF1777F2)])
              : null,
          color: enabled ? null : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)!.facebook,
                style: TextStyle(
                  color: Color(0xFF1877F2),
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 20),
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
                              prefixIcon: Icon(Icons.person),
                              hintText: AppLocalizations.of(context)!.name_label,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? AppLocalizations.of(context)!.name_required
                                : null,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: txtEmail,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: AppLocalizations.of(context)!.email_label,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) {
                                return AppLocalizations.of(context)!.email_required;
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return AppLocalizations.of(context)!.email_invalid;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: txtPassword,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: AppLocalizations.of(context)!.hint_password,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(context)!.password_required;
                              }
                              if (v.length < 6) {
                                return AppLocalizations.of(context)!.password_too_short;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: txtConfirm,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              hintText: AppLocalizations.of(context)!.confirm_password,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(context)!.confirm_password_required;
                              }
                              if (v != txtPassword.text) {
                                return AppLocalizations.of(context)!.password_mismatch;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 18),
                          _buildGradientButton(
                            AppLocalizations.of(context)!.register,
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
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.register_prompt, style: TextStyle(color: Colors.blue[700])),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

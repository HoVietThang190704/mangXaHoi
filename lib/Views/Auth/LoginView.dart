import 'package:mangxahoi/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:mangxahoi/Service/AuthService.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    assert(() {
      debugPaintSizeEnabled = false;
      debugPaintBaselinesEnabled = false;
      debugPaintPointersEnabled = false;
      debugPaintLayerBordersEnabled = false;
      return true;
    }());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      assert(() {
        debugPaintSizeEnabled = false;
        debugPaintBaselinesEnabled = false;
        debugPaintPointersEnabled = false;
        debugPaintLayerBordersEnabled = false;
        return true;
      }());
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    return raw.replaceFirst('Exception: ', '').trim();
  }

  Future<void> _submitLogin() async {
    if (_isLoading) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      Utils.userName = result.user?.userName ?? result.user?.email ?? _emailController.text.trim();

      if (!mounted) {
        return;
      }

      final message = (result.message.isNotEmpty)
          ? result.message
          : AppLocalizations.of(context)!.login_success;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      if (!mounted) {
        return;
      }
      final fallback = AppLocalizations.of(context)!.login_error;
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
    return Expanded(
      child: InkWell(
        onTap: (enabled && !isLoading && onTap != null) ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [Color(0xFF3AA0FF), Color(0xFF1777F2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: enabled ? null : Colors.grey,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFF7F9FB)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            (kDebugMode)
                ? Positioned(
                    top: 8,
                    right: 8,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        assert(() {
                          debugPaintSizeEnabled = false;
                          debugPaintBaselinesEnabled = false;
                          debugPaintPointersEnabled = false;
                          debugPaintLayerBordersEnabled = false;
                          return true;
                        }());
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Debug paint disabled')));
                      },
                      child: Icon(Icons.bug_report),
                    ),
                  )
                : SizedBox.shrink(),
            // Language chooser
            Positioned(
              top: 8,
              left: 8,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.language),
                onSelected: (value) {
                  Utils.setLocale(Locale(value));
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'en', child: Text('English')),
                  PopupMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.facebook,
                      style: TextStyle(
                        color: Color(0xFF1877F2),
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(color: Colors.black12, blurRadius: 6)],
                      )),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autovalidateMode: AutovalidateMode.disabled,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                                  hintText: AppLocalizations.of(context)!.hint_email,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return AppLocalizations.of(context)!.email_required;
                                  }
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(trimmed)) {
                                    return AppLocalizations.of(context)!.email_invalid;
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock, size: 20),
                                  hintText: AppLocalizations.of(context)!.hint_password,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.password_required;
                                  }
                                  if (value.length < 6) {
                                    return AppLocalizations.of(context)!.password_too_short;
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submitLogin(),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildGradientButton(AppLocalizations.of(context)!.register, () {
                                    Navigator.pushNamed(context, '/register');
                                  }),
                                  SizedBox(width: 12),
                                  _buildGradientButton(
                                    AppLocalizations.of(context)!.login,
                                    _submitLogin,
                                    isLoading: _isLoading,
                                    enabled: !_isLoading,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: Text(AppLocalizations.of(context)!.forgot_password, style: TextStyle(color: Colors.blue[700])),
                  ),
                  SizedBox(height: 18),
                  Text(AppLocalizations.of(context)!.create_account_text, style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

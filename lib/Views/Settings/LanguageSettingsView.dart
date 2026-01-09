import 'package:flutter/material.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class LanguageSettingsView extends StatefulWidget {
  const LanguageSettingsView({super.key});

  @override
  State<LanguageSettingsView> createState() => _LanguageSettingsViewState();
}

class _LanguageSettingsViewState extends State<LanguageSettingsView> {
  String _selected = 'vi';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = Utils.locale.value?.languageCode;
    _selected = current ?? 'vi';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Utils.setLocale(Locale(_selected));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.language_save_success)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.language_save_failed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.language_title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _languageTile(code: 'vi', label: l10n.language_vi),
            _languageTile(code: 'en', label: l10n.language_en),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(_saving ? l10n.common_saving : l10n.common_save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageTile({required String code, required String label}) {
    return Card(
      child: RadioListTile<String>(
        value: code,
        groupValue: _selected,
        onChanged: (value) {
          if (value != null) setState(() => _selected = value);
        },
        title: Text(label),
      ),
    );
  }
}

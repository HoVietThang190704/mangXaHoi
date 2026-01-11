import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/BottomNavigationBarComponent.dart';
import 'package:mangxahoi/Service/SessionService.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/services/api_service.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class SettingsHomeView extends StatelessWidget {
  const SettingsHomeView({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settings_logout_confirm_title),
        content: Text(l10n.settings_logout_confirm_message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.common_cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.settings_logout)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final api = await ApiService.create(enableLog: false);
        await api.logout();
      } catch (_) {
      }
      await SessionService.clearSession();
      if (Utils.navigatorKey.currentState != null) {
        Utils.navigatorKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils.selectIndex = 4; 
    final l10n = AppLocalizations.of(context)!;
    final sectionSpacing = SizedBox(height: 14);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.settings_title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          sectionSpacing,
          _SettingsCard(
            title: l10n.settings_account_center,
            items: [
              _SettingsItem(
                icon: Icons.manage_accounts_outlined,
                title: l10n.settings_edit_profile,
                subtitle: l10n.settings_edit_profile_desc,
                onTap: () => _navigate(context, '/settings/profile'),
              ),
              
              
              _SettingsItem(
                icon: Icons.lock_outline,
                title: l10n.settings_security,
                subtitle: l10n.settings_security_desc,
                onTap: () => _navigate(context, '/settings/security'),
              ),
            ],
          ),
          sectionSpacing,
          _SettingsCard(
            title: l10n.settings_help_feedback,
            items: [
              _SettingsItem(
                icon: Icons.chat_bubble_outline,
                title: l10n.settings_feedback,
                subtitle: l10n.settings_feedback_desc,
                onTap: () => _navigate(context, '/settings/feedback'),
              ),
            ],
          ),
          sectionSpacing,
          _SettingsCard(
            title: l10n.settings_options,
            items: [
              _SettingsItem(
                icon: Icons.language,
                title: l10n.settings_language,
                subtitle: l10n.settings_language_desc,
                onTap: () => _navigate(context, '/settings/language'),
              ),
              _SettingsItem(
                icon: Icons.logout,
                title: l10n.settings_logout,
                subtitle: l10n.settings_logout_desc,
                titleColor: Colors.red,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarComponent(),
    );
  }
}



class _SettingsCard extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

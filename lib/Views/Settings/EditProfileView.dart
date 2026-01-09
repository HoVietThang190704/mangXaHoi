import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';
import 'package:mangxahoi/Service/SessionService.dart';
import 'package:mangxahoi/Service/SettingsService.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _picker = ImagePicker();
  final _settingsService = SettingsService();

  AuthUserModel? _profile;
  bool _loadingProfile = true;
  bool _saving = false;
  File? _avatarFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    try {
      final profile = await _settingsService.fetchProfile();
      _applyProfile(profile);
    } catch (_) {
      if (Utils.currentUser != null) {
        _applyProfile(Utils.currentUser!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.login_error)),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  void _applyProfile(AuthUserModel profile) {
    _profile = profile;
    _nameController.text = profile.userName ?? '';
    _phoneController.text = profile.phone ?? '';
    _avatarUrl = profile.avatar;
    final address = profile.address;
    if (address != null) {
      final addressLine = address['detail']?.toString() ?? address['street']?.toString() ?? address['line1']?.toString() ?? '';
      _addressController.text = addressLine;
    }
    setState(() {});
  }

  Map<String, dynamic>? _buildAddress() {
    final addressLine = _addressController.text.trim();
    if (addressLine.isEmpty) return null;
    return {'detail': addressLine};
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      String? avatarUrl = _avatarUrl;
      if (_avatarFile != null) {
        avatarUrl = await _settingsService.uploadAvatar(_avatarFile!);
      }

      final updated = await _settingsService.updateProfile(
        userName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _buildAddress(),
        avatarUrl: avatarUrl,
      );

      await SessionService.updateUser(updated);
      _applyProfile(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thay đổi hồ sơ.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile_title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[100],
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _avatarFile != null
                                    ? FileImage(_avatarFile!)
                                    : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                        ? NetworkImage(_avatarUrl!) as ImageProvider
                                        : null,
                                child: (_avatarUrl == null && _avatarFile == null)
                                    ? const Icon(Icons.person, size: 42, color: Colors.white)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickAvatar,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _profile?.email ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildTextField(
                      controller: _nameController,
                      label: l10n.profile_display_name,
                      hint: l10n.profile_display_name_hint,
                      validator: (value) => (value == null || value.trim().isEmpty) ? l10n.name_required : null,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: l10n.profile_phone,
                      hint: l10n.profile_phone_hint,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return null; // optional
                        final regex = RegExp(r'^(\+84|84|0)[1-9][0-9]{8}$');
                        if (!regex.hasMatch(v)) {
                          return l10n.profile_phone_invalid;
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _addressController,
                      label: l10n.profile_address,
                      hint: l10n.profile_address_hint,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveProfile,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(_saving ? l10n.common_saving : l10n.common_save),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

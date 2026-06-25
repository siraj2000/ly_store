import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../widgets/common/app_header.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  String _avatarPath = '';
  bool _saving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileController>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _passwordController = TextEditingController();
    _avatarPath = user?.avatar ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final user = context.watch<ProfileController>().user;

    return Scaffold(
      appBar: AppHeader(
        title: context.tr('Edit Profile', 'تعديل الملف الشخصي'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primaryText.withValues(alpha: 0.97),
                    const Color(0xFF344B66),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _AvatarPreview(avatarPath: _avatarPath, size: 92),
                      PositionedDirectional(
                        bottom: 0,
                        end: 0,
                        child: InkWell(
                          onTap: _pickAvatarFromGallery,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: colors.icon,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.tr('Personal details', 'البيانات الشخصية'),
                    style: TextStyle(
                      color: colors.surface,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      'Update your profile photo, display name, phone number, email, and password in one place.',
                      'حدّث صورة الملف والاسم ورقم الهاتف والبريد الإلكتروني وكلمة المرور من مكان واحد.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.surface.withValues(alpha: 0.78),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _HeaderActionChip(
                        label: context.tr('Choose Photo', 'اختر صورة'),
                        onTap: _pickAvatarFromGallery,
                      ),
                      if (_avatarPath.isNotEmpty)
                        _HeaderActionChip(
                          label: context.tr('Remove Photo', 'إزالة الصورة'),
                          onTap: () => setState(() => _avatarPath = ''),
                          outlined: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Account information', 'معلومات الحساب'),
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(
                        'These details are shown across your customer profile and checkout flow.',
                        'تظهر هذه البيانات في ملفك كعميل وفي خطوات إتمام الطلب.',
                      ),
                      style: TextStyle(
                        color: colors.secondaryText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _nameController,
                      label: context.tr('Display name', 'الاسم المعروض'),
                      onChanged: (_) => setState(() {}),
                      validator: (value) => Validators.requiredField(
                        value,
                        label: context.tr('Display name', 'الاسم المعروض'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _emailController,
                      label: context.tr('Email address', 'البريد الإلكتروني'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _phoneController,
                      label: context.tr('Phone number', 'رقم الهاتف'),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passwordController,
                      label: context.tr('New password', 'كلمة المرور الجديدة'),
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      validator: _validateOptionalPassword,
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        'Leave the password field empty if you do not want to change it.',
                        'اترك حقل كلمة المرور فارغاً إذا كنت لا تريد تغييرها.',
                      ),
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              color: colors.icon,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr(
                                    'Profile preview',
                                    'معاينة الملف الشخصي',
                                  ),
                                  style: TextStyle(
                                    color: colors.primaryText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_nameController.text.trim().isEmpty ? user?.name ?? '' : _nameController.text.trim()}\n'
                                  '${_emailController.text.trim().isEmpty ? user?.email ?? '' : _emailController.text.trim()}\n'
                                  '${_phoneController.text.trim().isEmpty ? user?.phone ?? '' : _phoneController.text.trim()}',
                                  style: TextStyle(
                                    color: colors.secondaryText,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(context.tr('Cancel', 'إلغاء')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: _saving
                                ? context.tr('Saving...', 'جارٍ الحفظ...')
                                : context.tr('Save Changes', 'حفظ التغييرات'),
                            onPressed: _saving ? null : _saveProfile,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return context.tr('Email address is required', 'البريد الإلكتروني مطلوب');
    }
    if (!text.contains('@') || !text.contains('.')) {
      return context.tr(
        'Enter a valid email address',
        'أدخل بريداً إلكترونياً صالحاً',
      );
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return context.tr('Phone number is required', 'رقم الهاتف مطلوب');
    }
    if (text.length < 8) {
      return context.tr('Enter a valid phone number', 'أدخل رقم هاتف صالحاً');
    }
    return null;
  }

  String? _validateOptionalPassword(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (text.length < 6) {
      return context.tr('Use at least 6 characters', 'استخدم 6 أحرف على الأقل');
    }
    return null;
  }

  Future<void> _pickAvatarFromGallery() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (!mounted || file == null) {
        return;
      }
      setState(() => _avatarPath = file.path);
    } on MissingPluginException {
      if (!mounted) return;
      _showMessage(
        context.tr(
          'Restart the app once to enable gallery access.',
          'أعد تشغيل التطبيق مرة واحدة لتفعيل الوصول إلى المعرض.',
        ),
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      final code = error.code.toLowerCase();
      final message = (error.message ?? '').toLowerCase();
      if (code.contains('permission') || message.contains('permission')) {
        _showMessage(
          context.tr(
            'Photo library permission is required to choose a profile image.',
            'يلزم منح صلاحية المعرض لاختيار صورة الملف الشخصي.',
          ),
        );
        return;
      }
      _showMessage(
        context.tr(
          'Unable to open the gallery right now.',
          'تعذر فتح المعرض حالياً.',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        context.tr(
          'Unable to open the gallery right now.',
          'تعذر فتح المعرض حالياً.',
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    context.read<ProfileController>().updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      avatar: _avatarPath,
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'Profile updated successfully',
            'تم تحديث الملف الشخصي بنجاح',
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.avatarPath, required this.size});

  final String avatarPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasFile = avatarPath.isNotEmpty && File(avatarPath).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasFile
          ? Image.file(File(avatarPath), fit: BoxFit.cover)
          : Icon(Icons.person_outline, color: colors.icon, size: size * 0.44),
    );
  }
}

class _HeaderActionChip extends StatelessWidget {
  const _HeaderActionChip({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: outlined
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

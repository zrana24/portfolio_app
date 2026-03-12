import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final Color primaryPurple = const Color(0xFF35238A);
  final Color bgGrey = const Color(0xFFF3F4F6);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryPurple, size: 20),
        ),
        title: Text(
          "Şifre Değiştir",
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is PasswordChangeSuccess) {
            _showSnackBar(context, state.message, Colors.green);
            Navigator.pop(context);
          } else if (state is ProfileFailure) {
            _showSnackBar(context, state.message, Colors.red);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.04),

                  _buildInfoNote(size),

                  SizedBox(height: size.height * 0.04),

                  _buildModernPasswordField(
                    controller: _currentPasswordController,
                    label: 'MEVCUT ŞİFRE',
                    hint: 'Mevcut şifrenizi girin',
                    obscureText: _obscureCurrentPassword,
                    onToggleVisibility: () {
                      setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Mevcut şifrenizi girin';
                      return null;
                    },
                    size: size,
                  ),

                  SizedBox(height: size.height * 0.02),

                  _buildModernPasswordField(
                    controller: _newPasswordController,
                    label: 'YENİ ŞİFRE',
                    hint: 'Yeni şifrenizi girin',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Yeni şifrenizi girin';
                      if (value.length < 6) return 'Şifre en az 8 karakter '
                          'olmalıdır';
                      return null;
                    },
                    size: size,
                  ),

                  SizedBox(height: size.height * 0.02),

                  _buildModernPasswordField(
                    controller: _confirmPasswordController,
                    label: 'YENİ ŞİFRE (TEKRAR)',
                    hint: 'Yeni şifrenizi tekrar girin',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Şifrenizi tekrar girin';
                      if (value != _newPasswordController.text) return 'Şifreler eşleşmiyor';
                      return null;
                    },
                    size: size,
                  ),

                  SizedBox(height: size.height * 0.06),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(size.width * 0.08),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        'Şifreyi Güncelle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoNote(Size size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: primaryPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Şifrenizin en az 8 karakterden oluştuğundan "
                  "emin olun.",
              style: TextStyle(fontSize: size.width * 0.032, color: primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    required Size size,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.028,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 1.1,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          cursorColor: primaryPurple,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: size.width * 0.035, fontWeight: FontWeight.normal),
            prefixIcon: Icon(Icons.lock_person_outlined, color: primaryPurple, size: 20),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: bgGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.05),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(height: 0.8),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.05),
              borderSide: BorderSide(color: primaryPurple.withOpacity(0.3), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
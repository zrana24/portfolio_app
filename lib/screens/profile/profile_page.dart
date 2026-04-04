import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/nav.dart';
import '../../app/routes.dart';
import '../../widgets/footer.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deleteConfirmController = TextEditingController();
  bool _isEditing = false;
  String _email = '';

  final Color primaryPurple = const Color(0xFF1A0B52);
  final Color bgGrey = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadUserProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _deleteConfirmController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '905XXXXXXXXX'; // WhatsApp telefon numaranızı buraya yazın
    const message = 'Merhaba, yardıma ihtiyacım var.';
    final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp açılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: primaryPurple,
              size: size.width * 0.07,
            ),
            SizedBox(width: size.width * 0.03),
            const Text(
              'Hakkımızda',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cebeci Kıymetli Madenler',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w700,
                  color: primaryPurple,
                ),
              ),
              SizedBox(height: size.height * 0.015),
              Text(
                'Portföy yönetimi ve kıymetli maden takibi için geliştirilmiş modern bir platformdur.',
                style: TextStyle(
                  fontSize: size.width * 0.038,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: size.height * 0.02),
              _buildInfoRow(Icons.pin_drop_outlined, 'Adres', 'Konya, Türkiye', size),
              SizedBox(height: size.height * 0.012),
              _buildInfoRow(Icons.email_outlined, 'E-posta', 'info@cebecikiymetlimadenler.com', size),
              SizedBox(height: size.height * 0.012),
              _buildInfoRow(Icons.phone_outlined, 'Telefon', '+90 XXX XXX XX XX', size),
              SizedBox(height: size.height * 0.02),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: size.height * 0.015),
              Text(
                'Versiyon 1.0.0',
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Kapat',
              style: TextStyle(
                color: primaryPurple,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: size.width * 0.045,
          color: const Color(0xFF6B7280),
        ),
        SizedBox(width: size.width * 0.025),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.002),
              Text(
                value,
                style: TextStyle(
                  fontSize: size.width * 0.036,
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 4),
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _nameController.text = state.name;
              _phoneController.text = state.phone;
              _email = state.email;
            } else if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              setState(() => _isEditing = false);
            } else if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is LogoutSuccess || state is AccountDeleteSuccess) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            }
          },
          builder: (context, state) {
            if (state is ProfileUnauthenticated) {
              return Column(
                children: [
                  const CebeciAppBar(),
                  Expanded(child: _buildNotLoggedInState(size)),
                ],
              );
            }

            if (state is ProfileLoading && _email.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A0B52)),
              );
            }

            bool isLoggedIn = _email.isNotEmpty;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: CebeciAppBar()),
                _buildAppBar(size, isLoggedIn),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: size.height * 0.03),
                      _buildInfoTile("AD SOYAD", _nameController, Icons.person_outline, size),
                      SizedBox(height: size.height * 0.015),
                      _buildInfoTile("E-POSTA", TextEditingController(text: _email), Icons.mail_outline, size, isLocked: true),
                      SizedBox(height: size.height * 0.015),
                      _buildInfoTile("TELEFON", _phoneController, Icons.phone_android_outlined, size),
                      SizedBox(height: size.height * 0.03),

                      _buildSectionTitle("Ayarlar", size),
                      SizedBox(height: size.height * 0.012),
                      _buildMenuButton(
                        "Şifre Değiştir",
                        Icons.lock_outline_rounded,
                            () => Navigator.pushNamed(context, AppRoutes.changePassword),
                        size,
                      ),
                      SizedBox(height: size.height * 0.015),

                      _buildMenuButton(
                        "Hakkımızda",
                        Icons.info_outline_rounded,
                        _showAboutDialog,
                        size,
                      ),
                      SizedBox(height: size.height * 0.015),

                      _buildMenuButton(
                        "WhatsApp İletişim",
                        Icons.chat_bubble_outline_rounded,
                        _launchWhatsApp,
                        size,
                        iconColor: const Color(0xFF25D366),
                      ),

                      SizedBox(height: size.height * 0.04),
                      _buildLogoutButton(size),
                      SizedBox(height: size.height * 0.095 + bottomPadding),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotLoggedInState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: size.width * 0.25,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: size.height * 0.025),
            Text(
              "Profilinizi görüntülemek için\nlütfen giriş yapın.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            SizedBox(
              width: size.width * 0.6,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A0B52),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Size size, bool isLoggedIn) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(size.width * 0.06, size.width * 0.04, size.width * 0.06, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Profilim",
              style: TextStyle(
                fontSize: size.width * 0.07,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            if (isLoggedIn)
              GestureDetector(
                onTap: () {
                  if (_isEditing) {
                    context.read<ProfileBloc>().add(
                      UpdateUserProfile(
                        name: _nameController.text,
                        phone: _phoneController.text,
                      ),
                    );
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                child: _circularIcon(
                  _isEditing ? Icons.check : Icons.edit,
                  size,
                  color: _isEditing ? Colors.green.shade600 : const Color(0xFF1A1A1A),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, TextEditingController controller, IconData icon, Size size, {bool isLocked = false}) {
    bool active = _isEditing && !isLocked;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.045,
        vertical: size.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.035),
        border: Border.all(
          color: active ? primaryPurple : const Color(0xFFE5E7EB),
          width: active ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: active ? primaryPurple : const Color(0xFF6B7280),
            size: size.width * 0.05,
          ),
          SizedBox(width: size.width * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.028,
                    letterSpacing: 0.5,
                  ),
                ),
                TextField(
                  controller: controller,
                  enabled: active,
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Icon(
              Icons.lock_outline,
              size: size.width * 0.04,
              color: const Color(0xFF9CA3AF),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
      String title,
      IconData icon,
      VoidCallback onTap,
      Size size, {
        bool isDestructive = false,
        Color? iconColor,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(size.width * 0.035),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? (isDestructive ? Colors.red.shade600 : primaryPurple),
              size: size.width * 0.055,
            ),
            SizedBox(width: size.width * 0.03),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.04,
                color: isDestructive ? Colors.red.shade600 : const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: size.width * 0.05,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: Text(
          "Oturumu Kapat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size.width * 0.04,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.035),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size size) {
    return Text(
      title,
      style: TextStyle(
        color: primaryPurple,
        fontWeight: FontWeight.w700,
        fontSize: size.width * 0.045,
      ),
    );
  }

  Widget _circularIcon(IconData icon, Size size, {Color color = Colors.black87}) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.025),
      decoration: BoxDecoration(
        color: bgGrey,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, size: size.width * 0.045, color: color),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red.shade600,
              size: size.width * 0.07,
            ),
            SizedBox(width: size.width * 0.03),
            const Text(
              "Çıkış Yap",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          "Oturumu kapatmak istediğinize emin misiniz?",
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "İptal",
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfileBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              "Çıkış Yap",
              style: TextStyle(fontSize: size.width * 0.04),
            ),
          ),
        ],
      ),
    );
  }
}
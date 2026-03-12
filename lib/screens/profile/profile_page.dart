import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/nav.dart';
import '../../app/routes.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../widgets/footer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  String _email = '';

  final Color primaryPurple = const Color(0xFF35238A);
  final Color bgGrey = const Color(0xFFF3F4F6);
  final Color scaffoldBg = Colors.white;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: scaffoldBg,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _nameController.text = state.name;
              _phoneController.text = state.phone;
              _email = state.email;
            } else if (state is ProfileUpdateSuccess) {
              _showSnackBar(context, state.message, Colors.green);
              setState(() => _isEditing = false);
            } else if (state is ProfileFailure) {
              _showSnackBar(context, state.message, Colors.red);
            } else if (state is LogoutSuccess) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(size),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: size.height * 0.045),
                      _buildInfoTile("AD SOYAD", _nameController, Icons.person_outline, size),
                      SizedBox(height: size.height * 0.015),
                      _buildInfoTile("E-POSTA", TextEditingController(text: _email), Icons.mail_outline, size, isLocked: true),
                      SizedBox(height: size.height * 0.015),
                      _buildInfoTile("TELEFON", _phoneController, Icons.phone_android_outlined, size),

                      SizedBox(height: size.height * 0.04),
                      _buildSectionTitle("Ayarlar", size),
                      _buildMenuButton("Şifre Değiştir", Icons.lock_open_rounded, () {
                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      }, size),

                      SizedBox(height: size.height * 0.06),
                      _buildLogoutButton(size),
                      const SizedBox(height: 50),
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

  Widget _buildAppBar(Size size) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(size.width * 0.06, size.width * 0.06, size.width * 0.06, 0),
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
            GestureDetector(
              onTap: () {
                if (_isEditing) {
                  context.read<ProfileBloc>().add(UpdateUserProfile(
                    name: _nameController.text,
                    phone: _phoneController.text,
                  ));
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: _circularIcon(_isEditing ? Icons.check : Icons.edit, size,
                  color: _isEditing ? Colors.green : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, TextEditingController controller, IconData icon, Size size, {bool isLocked = false}) {
    bool active = _isEditing && !isLocked;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.012),
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(size.width * 0.06),
        border: active ? Border.all(color: primaryPurple.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? primaryPurple : Colors.grey, size: size.width * 0.05),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.028,
                    letterSpacing: 1.1,
                  ),
                ),
                TextField(
                  controller: controller,
                  enabled: active,
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: isLocked ? Colors.grey : Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 4),
                  ),
                ),
              ],
            ),
          ),
          if (isLocked) Icon(Icons.lock_outline, size: size.width * 0.04, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size size) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: primaryPurple,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.05,
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap, Size size) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: bgGrey, width: 2),
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryPurple, size: size.width * 0.05),
            SizedBox(width: size.width * 0.03),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.08),
          ),
        ),
      ),
    );
  }

  Widget _circularIcon(IconData icon, Size size, {Color color = Colors.black87}) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.025),
      decoration: BoxDecoration(color: bgGrey, shape: BoxShape.circle),
      child: Icon(icon, size: size.width * 0.05, color: color),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Çıkış Yap"),
        content: const Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(LogoutRequested());
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
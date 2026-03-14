import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final Color primaryPurple = const Color(0xFF35238A);
  final Color bgGrey = const Color(0xFFF3F4F6);

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _nameController.text = state.name;
              _phoneController.text = state.phone;
              _email = state.email;
            } else if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              setState(() => _isEditing = false);
            } else if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
              return const Center(child: CircularProgressIndicator());
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
                      SizedBox(height: size.height * 0.045),
                      _buildInfoTile("AD SOYAD", _nameController, Icons.person_outline, size),
                      SizedBox(height: size.height * 0.015),
                      _buildInfoTile("E-POSTA", TextEditingController(text: _email), Icons.mail_outline, size, isLocked: true),
                      SizedBox(height: size.height * 0.015),
                      _buildInfoTile("TELEFON", _phoneController, Icons.phone_android_outlined, size),
                      SizedBox(height: size.height * 0.04),
                      _buildSectionTitle("Ayarlar", size),
                      _buildMenuButton("Şifre Değiştir", Icons.lock_open_rounded, () => Navigator.pushNamed(context, AppRoutes.changePassword), size),
                      SizedBox(height: size.height * 0.015),
                      /*_buildMenuButton("Hesabı Sil", Icons
                .delete_forever_rounded, () => _showDeleteAccountDialog(context), size, isDestructive: true),
                      SizedBox(height: size.height * 0.06),*/
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

  Widget _buildNotLoggedInState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: size.width * 0.25, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "Profilinizi görüntülemek için\nlütfen giriş yapın.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Size size, bool isLoggedIn) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(size.width * 0.06, size.width * 0.05, size.width * 0.06, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Profilim", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
            if (isLoggedIn)
              GestureDetector(
                onTap: () {
                  if (_isEditing) {
                    context.read<ProfileBloc>().add(UpdateUserProfile(name: _nameController.text, phone: _phoneController.text));
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                child: _circularIcon(_isEditing ? Icons.check : Icons.edit, size, color: _isEditing ? Colors.green : Colors.black87),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, TextEditingController controller, IconData icon, Size size, {bool isLocked = false}) {
    bool active = _isEditing && !isLocked;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(20), border: active ? Border.all(color: primaryPurple.withOpacity(0.3)) : null),
      child: Row(
        children: [
          Icon(icon, color: active ? primaryPurple : Colors.grey, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.1)),
              TextField(controller: controller, enabled: active, decoration: const InputDecoration(isDense: true, border: InputBorder.none)),
            ]),
          ),
          if (isLocked) const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap, Size size, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: isDestructive ? Colors.red.shade100 : bgGrey, width: 2), borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
          Icon(icon, color: isDestructive ? Colors.red : primaryPurple, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : Colors.black87)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _buildLogoutButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: const Text("Oturumu Kapat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size size) => Text(title, style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 18));

  Widget _circularIcon(IconData icon, Size size, {Color color = Colors.black87}) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgGrey, shape: BoxShape.circle), child: Icon(icon, size: 20, color: color));

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Oturumu kapatmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
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


  void _showDeleteAccountDialog(BuildContext context) {
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Hesabı Sil"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bu işlem geri alınamaz. Hesabınızı silmek için lütfen mevcut şifrenizi girin.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Şifreniz",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_passwordController.text.isNotEmpty) {
                context.read<ProfileBloc>().add(DeleteAccountRequested(
                  password: _passwordController.text,
                  confirmation: 'DELETE',
                ));
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Lütfen şifrenizi girin."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Onayla ve Sil"),
          ),
        ],
      ),
    );
  }
}
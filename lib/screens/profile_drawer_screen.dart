import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_barista_app/screens/orders_screen.dart';
import '../core/constants/colors.dart';
import '../core/services/firebase_service.dart';
import 'profile_screen.dart';
import 'page2_login_screen.dart';
import 'find_barista_screen.dart';
import 'settings_screen.dart';
import 'payment_screen.dart';

class ProfileDrawerScreen extends StatefulWidget {
  const ProfileDrawerScreen({super.key});

  @override
  State<ProfileDrawerScreen> createState() => _ProfileDrawerScreenState();
}

class _ProfileDrawerScreenState extends State<ProfileDrawerScreen> {
  String _name      = '';
  String _email     = '';
  String _avatarUrl = '';
  bool   _loading   = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final uid = FirebaseService.currentUser?.uid;
    if (uid != null) {
      final data = await FirebaseService.getUser(uid);
      if (mounted) {
        setState(() {
          _name      = data?['nom']    as String? ?? 'Utilisateur';
          _email     = data?['email']  as String? ??
                       FirebaseService.currentUser?.email ?? '';
          _avatarUrl = data?['avatar'] as String? ?? '';
          _loading   = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Avatar ─────────────────────────────────────────────
  Widget _buildAvatar() {
    const double radius = 30;

    if (_avatarUrl.isNotEmpty &&
        (_avatarUrl.startsWith('http://') ||
         _avatarUrl.startsWith('https://'))) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: kInputBg,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl:  _avatarUrl,
            width:     radius * 2,
            height:    radius * 2,
            fit:       BoxFit.cover,
            placeholder: (_, __) => const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(color: kBrown, strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => const Icon(
                Icons.person, color: kBrownLight, size: 30),
          ),
        ),
      );
    }

    // Fallback: asset image
    return CircleAvatar(
      radius: radius,
      backgroundColor: kInputBg,
      backgroundImage: const AssetImage('assets/images/pic.png'),
      onBackgroundImageError: (_, __) {},
    );
  }

  // ── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final width     = MediaQuery.of(context).size.width;
    final height    = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: width, height: height,
        child: Stack(children: [

          // Dim overlay
          Positioned(
            left: 0, top: 0, bottom: 0,
            width: width * 0.22,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),

          // Drawer panel
          Positioned(
            right: 0, top: 0, bottom: 0,
            width: width * 0.78,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1008),
                borderRadius: BorderRadius.only(
                    topLeft:    Radius.circular(28),
                    bottomLeft: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPad + 20),

                  // ── User header ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(children: [
                      _loading
                          ? const CircleAvatar(
                              radius: 30, backgroundColor: Colors.white24)
                          : _buildAvatar(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _loading
                            ? _shimmerText()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name,
                                    style: const TextStyle(
                                        fontFamily:  'LeagueSpartan',
                                        color:       Colors.white,
                                        fontSize:    28,
                                        fontWeight:  FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _email,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'LeagueSpartan',
                                        color:      Color.fromARGB(255, 163, 137, 81),
                                        fontSize:   14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // ── Menu items ───────────────────────────
                  _DrawerItem(
                    assetIcon: 'assets/icons/order.png',
                    label:     'My Orders',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const OrdersScreen()));
                    },
                  ),
                  _divider(),

                  _DrawerItem(
                    assetIcon: 'assets/icons/prof.png',
                    label:     'My Profile',
                    onTap: () async {
                      Navigator.pop(context);
                      // Await so we can reload after user returns
                      await Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ProfileScreen()));
                      _loadUser(); // ← refreshes name + email + avatar
                    },
                  ),
                  _divider(),

                  _DrawerItem(
                    assetIcon: 'assets/icons/loc_2.png',
                    label:     "Choose your Barista's",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) =>
                              const FindBaristaScreen(fromDrawer: true)));
                    },
                  ),
                  _divider(),

                  _DrawerItem(
  assetIcon: 'assets/icons/payment.png',
  label:     'Payment Methods',
  onTap: () {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => const PaymentScreen()));
  },
),
                  _divider(),

                  _DrawerItem(
                    assetIcon: 'assets/icons/settings.png',
                    label:     'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const SettingsScreen()));
                    },
                  ),

                  const Spacer(),
                  _LogOutItem(onTap: () => _showLogoutDialog(context)),
                  SizedBox(height: bottomPad + 24),
                ],
              ),
            ),
          ),

          // Back arrow
          Positioned(
            top: topPad + 20, left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 28),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _divider() => const Divider(
      color: Colors.white, thickness: 1,
      indent: 24, endIndent: 24, height: 1);

  Widget _shimmerText() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 120, height: 22,
          decoration: BoxDecoration(color: Colors.white24,
              borderRadius: BorderRadius.circular(6))),
      const SizedBox(height: 6),
      Container(width: 170, height: 14,
          decoration: BoxDecoration(color: Colors.white12,
              borderRadius: BorderRadius.circular(6))),
    ],
  );

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'LeagueSpartan', color: kBrown,
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(height: 50,
                  decoration: BoxDecoration(color: const Color(0xFFE0DAD4),
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: const Text('Cancel', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: kBrown,
                      fontSize: 16, fontWeight: FontWeight.w700))),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () async {
                await FirebaseService.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false);
                }
              },
              child: Container(height: 50,
                  decoration: BoxDecoration(color: Colors.red,
                      borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: const Text('Yes, logout', style: TextStyle(
                      fontFamily: 'LeagueSpartan', color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w700))),
            )),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ── Drawer menu item ─────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final String assetIcon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({
      required this.assetIcon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(assetIcon, fit: BoxFit.contain,
                color: const Color(0xFF8D491E),
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.circle, color: Color(0xFF8D491E), size: 20)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(
            fontFamily: 'LeagueSpartan', color: Colors.white,
            fontSize: 24, fontWeight: FontWeight.w500))),
      ]),
    ),
  );
}

// ── Log out item ─────────────────────────────────────────
class _LogOutItem extends StatelessWidget {
  final VoidCallback onTap;
  const _LogOutItem({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset('assets/icons/logout.png',
                color: Colors.redAccent, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.logout, color: Colors.redAccent, size: 20)),
          ),
        ),
        const SizedBox(width: 16),
        const Text('Log Out', style: TextStyle(
            fontFamily: 'LeagueSpartan', color: Colors.white,
            fontSize: 25, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}
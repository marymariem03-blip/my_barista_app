// lib/screens/help_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/colors.dart';
import 'main_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _mainTab = 0;
  int _subTab  = 0;
  int _expanded = 0;

  final Map<int, List<_FaqItem>> _faqs = {
    0: [
      _FaqItem(question: 'What are your opening hours?',
          answer: 'Our hours vary by location. Check our website to see the specific schedule for your favorite Barista.'),
      _FaqItem(question: 'Where can I find nutritional information?',
          answer: 'Detailed ingredient lists are available in the item description when you tap on a drink or snack.'),
      _FaqItem(question: 'How do I use my "Free Drink" reward?',
          answer: 'Once you hit 2000 beans, a "Redeem" button will appear on your checkout screen.'),
      _FaqItem(question: 'Do you offer Wi-Fi in all branches?',
          answer: 'Yes! Ask any of our baristas for the daily password or check your digital receipt.'),
      _FaqItem(question: 'Lorem ipsum dolor sit amet?',
          answer: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore.'),
    ],
    1: [
      _FaqItem(question: 'How do I earn "Beans"?',
          answer: 'You earn 10 beans for every order. Just make sure you are logged in when you place your order!'),
      _FaqItem(question: 'Can I transfer my points to a friend?',
          answer: 'Currently, "Beans" are non-transferable, but you can always use them to buy a drink for a friend!'),
      _FaqItem(question: 'How do I update my phone number or email?',
          answer: 'Head to Profile > Edit Info. You\'ll need to verify your new contact details via a quick SMS/Email code.'),
    ],
    2: [
      _FaqItem(question: 'What if my drink is cold by the time I arrive?',
          answer: 'We recommend arriving within 5-10 minutes of your "Ready" notification to ensure the perfect temperature.'),
      _FaqItem(question: 'Do you offer delivery?',
          answer: 'Currently, we offer "Pick-up" and "Curbside" options. Check back soon for delivery updates!'),
      _FaqItem(question: 'What is your refund policy?',
          answer: 'If you canceled your order in time or there was a quality issue, refunds are processed within 3-5 business days.'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      // ✅ SharedNavBar
      bottomNavigationBar: SharedNavBar(activeIndex: -1),
      body: Column(children: [

        // ── Header ──────────────────────────────────
        Container(
          color: kBrown,
          padding: EdgeInsets.only(
              top: topPad + 14, left: 20, right: 20, bottom: 16),
          child: Stack(alignment: Alignment.center, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 34),
              ),
            ),
            Column(children: [
              const Text('Help', style: TextStyle(
                  fontFamily: 'LeagueSpartan', color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('How Can We Help You?',
                  style: TextStyle(fontFamily: 'LeagueSpartan',
                      color: Colors.white.withOpacity(0.7), fontSize: 13)),
            ]),
          ]),
        ),

        // ── Content ─────────────────────────────────
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const SizedBox(height: 16),

              // Main tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(color: kBg,
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.all(3),
                  child: Row(children: [
                    _MainTab(label: 'FAQ', isActive: _mainTab == 0,
                        onTap: () => setState(() => _mainTab = 0)),
                    _MainTab(label: 'Contact Us', isActive: _mainTab == 1,
                        onTap: () => setState(() => _mainTab = 1)),
                  ]),
                ),
              ),
              const SizedBox(height: 14),

              // Sub-tabs (FAQ only)
              if (_mainTab == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SubTab(label: 'General', isActive: _subTab == 0,
                          onTap: () => setState(() { _subTab = 0; _expanded = -1; })),
                      const SizedBox(width: 8),
                      _SubTab(label: 'Account', isActive: _subTab == 1,
                          onTap: () => setState(() { _subTab = 1; _expanded = -1; })),
                      const SizedBox(width: 8),
                      _SubTab(label: 'Services', isActive: _subTab == 2,
                          onTap: () => setState(() { _subTab = 2; _expanded = -1; })),
                    ],
                  ),
                ),
              const SizedBox(height: 8),

              Expanded(
                child: _mainTab == 0
                    ? _FaqList(
                        items:    _faqs[_subTab] ?? [],
                        expanded: _expanded,
                        onToggle: (i) => setState(() =>
                            _expanded = _expanded == i ? -1 : i),
                      )
                    : const _ContactUs(),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Main tab ──────────────────────────────────────────
class _MainTab extends StatelessWidget {
  final String label; final bool isActive; final VoidCallback onTap;
  const _MainTab({required this.label, required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: isActive ? kBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(28)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
            fontFamily: 'LeagueSpartan',
            color: isActive ? Colors.white : kBrown,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
      ),
    ),
  );
}

// ── Sub tab ───────────────────────────────────────────
class _SubTab extends StatelessWidget {
  final String label; final bool isActive; final VoidCallback onTap;
  const _SubTab({required this.label, required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
          color: isActive ? kBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? kBrown : Colors.black26, width: 1)),
      child: Text(label, style: TextStyle(
          fontFamily: 'LeagueSpartan',
          color: isActive ? Colors.white : kBrown.withOpacity(0.6),
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
    ),
  );
}

// ── FAQ list ──────────────────────────────────────────
class _FaqList extends StatelessWidget {
  final List<_FaqItem> items;
  final int expanded;
  final ValueChanged<int> onToggle;
  const _FaqList({required this.items, required this.expanded,
      required this.onToggle});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    itemCount: items.length,
    separatorBuilder: (_, __) => Divider(
        color: kBrown.withOpacity(0.1), height: 1, thickness: 1),
    itemBuilder: (_, i) {
      final item   = items[i];
      final isOpen = expanded == i;
      return GestureDetector(
        onTap: () => onToggle(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(item.question,
                    style: const TextStyle(fontFamily: 'LeagueSpartan',
                        color: kBrown, fontSize: 15,
                        fontWeight: FontWeight.w600))),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: kBrown.withOpacity(0.6), size: 22),
                ),
              ]),
              if (isOpen) ...[
                const SizedBox(height: 10),
                Text(item.answer, style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.65),
                    fontSize: 13, height: 1.5)),
              ],
            ],
          ),
        ),
      );
    },
  );
}

// ── Contact Us ────────────────────────────────────────
class _ContactUs extends StatelessWidget {
  const _ContactUs();

  static const _links = [
    _SocialLink(icon: 'assets/icons/global.png',
        iconW: 34.0, iconH: 33.56,
        label: 'Website',
        url: 'https://mybarista.com',
        fallback: Icons.language),
    _SocialLink(icon: 'assets/icons/facebook.png',
        iconW: 35.45, iconH: 35.34,
        label: 'Facebook',
        url: 'https://facebook.com/mybarista',
        fallback: Icons.facebook),
    _SocialLink(icon: 'assets/icons/Instagram.png',
        iconW: 35.44, iconH: 35.34,
        label: 'Instagram',
        url: 'https://instagram.com/mybarista',
        fallback: Icons.camera_alt_outlined),
  ];

  // ✅ Launch URL
  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open $url',
              style: const TextStyle(fontFamily: 'LeagueSpartan')),
          backgroundColor: kBrown,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _links.map((link) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () => _launch(context, link.url), // ✅ works now
          child: Row(children: [
            Image.asset(link.icon,
                width: link.iconW, height: link.iconH,
                color: const Color(0xFF31190A),
                errorBuilder: (ctx, e, s) =>
                    Icon(link.fallback,
                        color: const Color(0xFF31190A), size: 34)),
            const SizedBox(width: 16),
            Text(link.label, style: const TextStyle(
                fontFamily: 'LeagueSpartan',
                color: Color(0xFF31190A),
                fontSize: 16, fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF31190A))),
          ]),
        ),
      )).toList(),
    ),
  );
}

// ── Models ────────────────────────────────────────────
class _SocialLink {
  final String icon, label, url;
  final double iconW, iconH;
  final IconData fallback;
  const _SocialLink({required this.icon, required this.iconW,
      required this.iconH, required this.label,
      required this.url, required this.fallback});
}

class _FaqItem {
  final String question, answer;
  const _FaqItem({required this.question, required this.answer});
}
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/primary_button.dart';
import 'page2_login_screen.dart';
import 'page3_signup_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size    = MediaQuery.of(context).size;
    final topPad  = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [

          // ── Dark upper hero section ──────────────────
          SizedBox(
            height: size.height * 0.55,
            width: double.infinity,
            child: Stack(
              children: [

                // Dark background
                Container(
                  color: kBrown,
                  width: double.infinity,
                  height: size.height * 0.52,
                ),

                // Headline text
                Positioned(
                  top: topPad + 48,
                  left: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Click', style: _heroStyle(size)),
                      Text('Pick ',  style: _heroStyle(size)),
                      Text('Sip',    style: _heroStyle(size)),
                    ],
                  ),
                ),

                // Coffee cup
                Positioned(
                  right: 0,
                  bottom: -80,
                  height: size.height * 0.46,
                  child: Image.asset(
                    'assets/images/cup.png',
                    fit: BoxFit.contain,
                  ),
                ),

                // Wave
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: CustomPaint(
                    size: Size(size.width, 56),
                    painter: _BgWavePainter(),
                  ),
                ),
              ],
            ),
          ),

          // ── Light lower section ──────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ✅ Beans reward row — responsive
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 52, height: 52,
                        decoration: const BoxDecoration(
                            color: kBrown, shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/icons/coffee.png',
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, e, s) =>
                                const Icon(Icons.coffee,
                                    color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ✅ Text wrapped in Expanded to prevent overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collect 2000 Beans',
                              style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                color: kBrown,
                                fontSize: size.width * 0.038,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // ✅ FittedBox scales text to fit width
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'GET A FREE DRINK!',
                                style: TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  color: kBrown,
                                  fontSize: size.width * 0.075,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Log In button
                  PrimaryButton(
                    label: 'Log In',
                    backgroundColor: const Color(0xFF31190A),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen())),
                  ),
                  const SizedBox(height: 14),

                  // Sign Up button
                  PrimaryButton(
                    label: 'Sign Up',
                    backgroundColor: kBrownLight,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const SignUpScreen())),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Responsive hero font size
  TextStyle _heroStyle(Size size) => TextStyle(
    fontFamily: 'LeagueSpartan',
    fontSize: size.width * 0.165,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    height: 1.05,
  );
}

class _BgWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kBg;
    final path  = Path();

    path.moveTo(0, size.height * 0.4);

    path.quadraticBezierTo(
        size.width * 0.12, -10, size.width * 0.25, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.38, size.height * 0.8, size.width * 0.50, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.62, -10, size.width * 0.75, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.85, size.height * 0.7, size.width * 0.92, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.97, -10, size.width * 1.5, size.height * 0.4);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
import 'package:flutter/material.dart';
import 'package:workwise/screens/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D5D9D);
    const deepNavy = Color(0xFF17335C);
    const accentGreen = Color(0xFF3AA76D);
    const mutedText = Color(0xFF8090A4);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'WorkWise',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: deepNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8EDF4)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F2F54),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: accentGreen,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'SECURE ACCESS',
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'USER NAME',
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Employee ID or Email',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA8B5C4),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF7C8CA0),
                              size: 18,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'PASSWORD',
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '.......',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA8B5C4),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.key_outlined,
                              color: Color(0xFF7C8CA0),
                              size: 18,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF7C8CA0),
                                size: 18,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const DashboardPage(),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: const Text(
                              'LOGIN',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: accentGreen),
                            SizedBox(width: 8),
                            Text(
                              'SYSTEM ONLINE',
                              style: TextStyle(
                                color: Color(0xFF8C9AAD),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'v2.1 PROD',
                              style: TextStyle(
                                color: Color(0xFF8C9AAD),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomStatusItem(
                        icon: Icons.shield_outlined,
                        label: 'ENCRYPTED',
                      ),
                      _BottomStatusItem(
                        icon: Icons.domain_verification_outlined,
                        label: 'HUB ACCESS',
                      ),
                      _BottomStatusItem(
                        icon: Icons.cloud_outlined,
                        label: 'CLOUD PORTAL',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomStatusItem extends StatelessWidget {
  const _BottomStatusItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFA5B1BF)),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA5B1BF),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

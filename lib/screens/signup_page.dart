import 'package:flutter/material.dart';
import 'package:workwise/screens/dashboard_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17335C);
    const accentBlue = Color(0xFF0D5D9D);
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
                    'Workwise',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                              Icons.person_add_alt_1_rounded,
                              size: 18,
                              color: accentGreen,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'NEW ACCOUNT',
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
                          'EMAIL',
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'you@workwise.com',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA8B5C4),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
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
                                color: accentBlue,
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
                            hintText: 'Create a password',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA8B5C4),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
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
                                color: accentBlue,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CONFIRM PASSWORD',
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Re-enter your password',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA8B5C4),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF7C8CA0),
                              size: 18,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
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
                                color: accentBlue,
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
                              backgroundColor: accentBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'SIGN UP',
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
                              'READY TO REGISTER',
                              style: TextStyle(
                                color: Color(0xFF8C9AAD),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'SECURE MODE',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

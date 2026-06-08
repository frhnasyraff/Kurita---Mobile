import 'package:flutter/material.dart';
import 'package:workwise/screens/login_page.dart';
import 'package:workwise/screens/signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17335C);
    const secondaryText = Color(0xFF6F8096);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14213A5A),
                            blurRadius: 32,
                            offset: Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                color: primary,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Workwise',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose how you want to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: secondaryText, height: 1.5),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'LOG IN',
                                style: TextStyle(
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SignUpPage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              side: const BorderSide(color: Color(0xFFCAD6E4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'Android build ready - Version 1.0.0',
                        style: TextStyle(
                          color: Color(0xFF7B8A9D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

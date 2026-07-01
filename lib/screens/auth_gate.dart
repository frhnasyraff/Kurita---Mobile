import 'package:flutter/material.dart';
import 'package:workwise/services/api_client.dart';
import 'package:workwise/screens/login_page.dart';
import 'package:workwise/screens/operational_hub_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiClient.instance.isLoggedIn
        ? const OperationalHubPage()
        : const LoginPage();
  }
}
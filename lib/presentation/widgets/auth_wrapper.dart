import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../screens/initial_setup_screen.dart';
import '../screens/user_selection_screen.dart';
import '../screens/customer_list_screen.dart';

/// Auth wrapper - handles routing based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while initializing
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If no users exist, show initial setup
        if (!authProvider.hasUsers) {
          return const InitialSetupScreen();
        }

        // If not logged in, show user selection
        if (!authProvider.isLoggedIn) {
          return const UserSelectionScreen();
        }

        // User is logged in, show main app
        return const CustomerListScreen();
      },
    );
  }
}

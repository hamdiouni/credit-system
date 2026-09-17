import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/models/user.dart';

/// Initial setup screen for first-time app launch
/// Creates the first admin user
class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({Key? key}) : super(key: key);

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Welcome header
              _buildHeader(),
              const SizedBox(height: 48),

              // Setup form
              _buildForm(),
              const SizedBox(height: 32),

              // Create button
              _buildCreateButton(),
              const SizedBox(height: 16),

              // Info text
              _buildInfoText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.security,
            size: 50,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        const Text(
          'Welcome to Credit Manager',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Let\'s set up your admin account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username field
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // PIN field
          TextFormField(
            controller: _pinController,
            decoration: InputDecoration(
              labelText: 'PIN (4-6 digits)',
              hintText: 'Enter your PIN',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePin ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePin = !_obscurePin;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a PIN';
              }
              if (value.length < 4) {
                return 'PIN must be at least 4 digits';
              }
              if (!RegExp(r'^\d+$').hasMatch(value)) {
                return 'PIN must contain only numbers';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Confirm PIN field
          TextFormField(
            controller: _confirmPinController,
            decoration: InputDecoration(
              labelText: 'Confirm PIN',
              hintText: 'Re-enter your PIN',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPin ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPin = !_obscureConfirmPin;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: _obscureConfirmPin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your PIN';
              }
              if (value != _pinController.text) {
                return 'PINs do not match';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _createAdminUser(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _createAdminUser,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Create Admin Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Important Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• This will be your admin account with full access\n'
            '• You can create additional users later\n'
            '• Keep your PIN secure and memorable\n'
            '• You can change your PIN in settings',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAdminUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth provider
      final authProvider = context.read<AuthProvider>();
      
      // Create first user (bypasses permission check)
      await authProvider.createFirstUser(
        username: _usernameController.text.trim(),
        pin: _pinController.text,
      );

      print('✅ [InitialSetup] User created successfully');

      // Now login with the created user
      final loginSuccess = await authProvider.login(
        _usernameController.text.trim(),
        _pinController.text,
      );

      print('🔐 [InitialSetup] Login result: $loginSuccess');

      if (mounted) {
        if (loginSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Admin account created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // The AuthWrapper will automatically navigate to CustomerListScreen
          // because authProvider.isLoggedIn will now be true
        } else {
          throw Exception('Login failed after user creation');
        }
      }
    } catch (e) {
      print('❌ [InitialSetup] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

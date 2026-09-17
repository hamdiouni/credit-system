import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/models/user.dart';

/// PIN login screen for user authentication
class PinLoginScreen extends StatefulWidget {
  final User user;
  final VoidCallback onSuccess;

  const PinLoginScreen({
    Key? key,
    required this.user,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final List<String> _pin = [];
  final int _pinLength = 4;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // User info
                _buildUserInfo(),
                const SizedBox(height: 48),

                // PIN dots
                _buildPinDots(),
                const SizedBox(height: 16),

                // Error message
                if (_errorMessage != null) _buildErrorMessage(),
                const SizedBox(height: 32),

                // Number pad
                _buildNumberPad(),
                const SizedBox(height: 24),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        // User avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 40,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),

        // Username
        Text(
          widget.user.username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Role
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: widget.user.role == UserRole.admin
                ? Colors.purple.shade100
                : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.user.role.displayName,
            style: TextStyle(
              fontSize: 12,
              color: widget.user.role == UserRole.admin
                  ? Colors.purple.shade700
                  : Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Instruction
        Text(
          'Enter your PIN',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.blue.shade600 : Colors.grey.shade300,
            border: Border.all(
              color: isFilled ? Colors.blue.shade600 : Colors.grey.shade400,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow([1, 2, 3]),
        const SizedBox(height: 12),
        _buildNumberRow([4, 5, 6]),
        const SizedBox(height: 12),
        _buildNumberRow([7, 8, 9]),
        const SizedBox(height: 12),
        _buildNumberRow([null, 0, -1]), // null = empty, -1 = backspace
      ],
    );
  }

  Widget _buildNumberRow(List<int?> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        if (number == null) {
          return const SizedBox(width: 80, height: 80);
        }

        if (number == -1) {
          // Backspace button
          return _buildNumberButton(
            child: const Icon(Icons.backspace_outlined),
            onTap: _onBackspace,
          );
        }

        // Number button
        return _buildNumberButton(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => _onNumberTap(number),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  void _onNumberTap(int number) {
    if (_pin.length >= _pinLength) return;

    setState(() {
      _pin.add(number.toString());
      _errorMessage = null;
    });

    // Auto-submit when PIN is complete
    if (_pin.length == _pinLength) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin.removeLast();
      _errorMessage = null;
    });
  }

  Future<void> _submitPin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final pinString = _pin.join();

    try {
      // Use AuthProvider instead of AuthService directly
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(widget.user.username, pinString);

      if (success) {
        // Login successful
        widget.onSuccess();
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        // Login failed
        setState(() {
          _errorMessage = 'Invalid PIN';
          _pin.clear();
          _isLoading = false;
        });

        // Vibrate or show feedback
        _showErrorFeedback();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login error';
        _pin.clear();
        _isLoading = false;
      });
    }
  }

  void _showErrorFeedback() {
    // Shake animation or haptic feedback could be added here
  }
}

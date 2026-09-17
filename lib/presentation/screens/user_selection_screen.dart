import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/models/user.dart';
import 'pin_login_screen.dart';

/// User selection screen - shows list of users to login
class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({Key? key}) : super(key: key);

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      // Get users directly from repository (bypass permission check for login screen)
      final users = await authProvider.getAllUsersForLogin();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        const SizedBox(height: 40),
        
        // Header
        _buildHeader(),
        const SizedBox(height: 32),

        // User list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              return _buildUserCard(_users[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),

        // Title
        const Text(
          'Credit Manager',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle
        Text(
          'Select your account',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectUser(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: user.role == UserRole.admin
                      ? Colors.purple.shade100
                      : Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: user.role == UserRole.admin
                      ? Colors.purple.shade700
                      : Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user.role == UserRole.admin
                            ? Colors.purple.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.role.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: user.role == UserRole.admin
                              ? Colors.purple.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectUser(User user) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PinLoginScreen(
          user: user,
          onSuccess: () {
            // Don't navigate here - AuthWrapper will handle it automatically
            // when it detects the user is logged in
          },
        ),
      ),
    );

    // If login was successful, the AuthWrapper will automatically
    // show the CustomerListScreen because authProvider.isLoggedIn is now true
  }
}

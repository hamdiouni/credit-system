import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/models/user.dart';
import '../../widgets/confirmation_dialog.dart';

/// User Management Screen - Admin only
/// Allows admins to manage users (add, edit, delete, reset PIN)
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final users = await authProvider.getAllUsers();
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? _buildEmptyState()
              : _buildUserList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) => _buildUserCard(_users[index]),
    );
  }

  Widget _buildUserCard(User user) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final isCurrentUser = currentUser?.id == user.id;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.role == UserRole.admin ? Colors.purple.shade100 : Colors.blue.shade100,
          child: Icon(
            Icons.person,
            color: user.role == UserRole.admin ? Colors.purple.shade700 : Colors.blue.shade700,
          ),
        ),
        title: Row(
          children: [
            Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('You', style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.role.displayName),
            if (!user.isActive) ...[
              const SizedBox(height: 4),
              Text('Inactive', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'reset_pin', child: Text('Reset PIN')),
            if (user.isActive)
              const PopupMenuItem(value: 'deactivate', child: Text('Deactivate'))
            else
              const PopupMenuItem(value: 'activate', child: Text('Activate')),
            if (!isCurrentUser)
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(String action, User user) async {
    switch (action) {
      case 'reset_pin':
        await _showResetPinDialog(user);
        break;
      case 'activate':
        await _activateUser(user);
        break;
      case 'deactivate':
        await _deactivateUser(user);
        break;
      case 'delete':
        await _deleteUser(user);
        break;
    }
  }

  Future<void> _showAddUserDialog() async {
    final usernameController = TextEditingController();
    final pinController = TextEditingController();
    UserRole selectedRole = UserRole.employee;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  decoration: const InputDecoration(labelText: 'PIN (4-6 digits)'),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty || pinController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                
                try {
                  await context.read<AuthProvider>().createUser(
                    username: usernameController.text,
                    pin: pinController.text,
                    role: selectedRole,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
      }
    }
  }

  Future<void> _showResetPinDialog(User user) async {
    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset PIN for ${user.username}'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(labelText: 'New PIN (4-6 digits)'),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.isEmpty) return;
              
              try {
                await context.read<AuthProvider>().resetUserPin(user.id, pinController.text);
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN reset successfully')),
      );
    }
  }

  Future<void> _activateUser(User user) async {
    try {
      await context.read<AuthProvider>().activateUser(user.id);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.username} activated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deactivateUser(User user) async {
    final confirmed = await ConfirmationDialog.showWarning(
      context: context,
      title: 'Deactivate User',
      message: 'Are you sure you want to deactivate ${user.username}?',
      confirmText: 'Deactivate',
      cancelText: 'Cancel',
    );

    if (!confirmed) return;

    try {
      await context.read<AuthProvider>().deactivateUser(user.id);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.username} deactivated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await ConfirmationDialog.showDeleteConfirmation(
      context: context,
      title: 'Delete User',
      message: 'Are you sure you want to delete ${user.username}? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (!confirmed) return;

    try {
      await context.read<AuthProvider>().deleteUser(user.id);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.username} deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

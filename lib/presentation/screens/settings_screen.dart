import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/localization_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../generated/app_localizations.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../config/database_config.dart';
import 'data_migration_screen.dart';
import 'user_management_screen.dart';
import 'audit_log_screen.dart';
import 'backup_restore_screen.dart';
import 'monitoring_screen.dart';
import 'help_documentation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String _appVersion = '1.0.0';

  Future<void> _showAboutDialog() async {
    final l10n = AppLocalizations.of(context);
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: _appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
      ),
      children: const [
        SizedBox(height: 16),
        Text('A professional credit management application for small businesses.'),
        SizedBox(height: 8),
        Text('Features:'),
        Text('• Customer management'),
        Text('• Credit tracking'),
        Text('• Payment processing'),
        Text('• Balance credit system'),
        Text('• PDF & CSV export'),
        Text('• Multi-language support'),
      ],
    );
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context);
    
    final confirmed = await ConfirmationDialog.showDeleteConfirmation(
      context: context,
      title: 'Clear All Data',
      message: 'This will permanently delete ALL customers and transactions.\n\nThis action cannot be undone!\n\nAre you absolutely sure?',
      confirmText: 'Delete Everything',
      cancelText: l10n.cancel,
    );

    if (!confirmed || !mounted) return;

    // Second confirmation for safety
    final doubleConfirmed = await ConfirmationDialog.showWarning(
      context: context,
      title: 'Final Confirmation',
      message: 'Last chance! This will delete everything.\n\nProceed with deletion?',
      confirmText: 'Yes, Delete All',
      cancelText: 'No, Go Back',
    );

    if (!doubleConfirmed || !mounted) return;

    try {
      // TODO: Implement clear all data functionality in provider
      // await context.read<CustomerProvider>().clearAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Clear all data feature coming soon')),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 2,
      ),
      body: Consumer<LocalizationProvider>(
        builder: (context, localization, _) {
          return ListView(
            children: [
              // Language Section
              _SectionHeader(title: 'Language & Region'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.language, color: Colors.blue),
                  title: Text(l10n.language),
                  subtitle: Text(_getLanguageName(localization.languageCode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(localization),
                ),
              ),

              const SizedBox(height: 16),

              // Help & Documentation Section
              _SectionHeader(title: 'Help & Support'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: const Text('User Documentation'),
                  subtitle: const Text('View user guide with diagrams'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpDocumentationScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Statistics Section
              _SectionHeader(title: 'Statistics'),
              Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  final totalCustomers = provider.customersWithDebt.length;
                  final withDebt = provider.customersWithDebt.where((c) => c.remainingDebt > 0).length;
                  final totalDebt = provider.customersWithDebt.fold<double>(0, (sum, c) => sum + c.remainingDebt);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.people, color: Colors.green),
                          title: const Text('Total Customers'),
                          trailing: Text(
                            totalCustomers.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.warning_amber, color: Colors.orange),
                          title: const Text('Customers with Debt'),
                          trailing: Text(
                            withDebt.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.trending_up, color: Colors.red),
                          title: const Text('Total Outstanding Debt'),
                          trailing: Text(
                            '${totalDebt.toStringAsFixed(2)} TND',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Security Section (Admin only)
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (!authProvider.isLoggedIn) return const SizedBox.shrink();
                  
                  return Column(
                    children: [
                      _SectionHeader(title: 'Security'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.lock, color: Colors.blue),
                              title: const Text('Change PIN'),
                              subtitle: const Text('Update your login PIN'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showChangePinDialog(authProvider),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.timer, color: Colors.orange),
                              title: const Text('Auto-Lock Timeout'),
                              subtitle: Text('${authProvider.autoLockTimeout} minutes'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showAutoLockDialog(authProvider),
                            ),
                            if (authProvider.isAdmin) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.people, color: Colors.purple),
                                title: const Text('User Management'),
                                subtitle: const Text('Manage users and permissions'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UserManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.history, color: Colors.green),
                                title: const Text('Audit Log'),
                                subtitle: const Text('View system activity'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AuditLogScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.logout, color: Colors.red),
                              title: const Text('Logout'),
                              subtitle: const Text('Sign out of your account'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _logout(authProvider),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

              // Database Section
              _SectionHeader(title: 'Database'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        DatabaseConfig.isOfflineFirst ? Icons.storage : Icons.cloud,
                        color: DatabaseConfig.isOfflineFirst ? Colors.green : Colors.blue,
                      ),
                      title: const Text('Current Database'),
                      subtitle: Text(
                        DatabaseConfig.isOfflineFirst
                            ? 'SQLite (Offline-first)'
                            : 'MongoDB (Cloud-based)',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DatabaseConfig.isOfflineFirst ? Colors.green.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DatabaseConfig.isOfflineFirst ? 'OFFLINE' : 'ONLINE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: DatabaseConfig.isOfflineFirst ? Colors.green.shade700 : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.sync_alt, color: Colors.purple),
                      title: const Text('Data Migration'),
                      subtitle: const Text('Migrate from MongoDB to SQLite'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DataMigrationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data Management Section
              _SectionHeader(title: 'Data Management'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.backup, color: Colors.blue),
                      title: const Text('Backup & Restore'),
                      subtitle: const Text('Create backups and restore data'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupRestoreScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.file_download, color: Colors.green),
                      title: const Text('Export to CSV'),
                      subtitle: const Text('Export all data to CSV'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate back and trigger CSV export
                        Navigator.pop(context);
                        // The export button is in the customer list
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Clear All Data'),
                      subtitle: const Text('Permanently delete everything'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _clearAllData,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Developer Section (Admin only)
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (!authProvider.isAdmin) return const SizedBox.shrink();
                  
                  return Column(
                    children: [
                      _SectionHeader(title: 'Developer'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.monitor_heart, color: Colors.purple),
                          title: const Text('System Monitoring'),
                          subtitle: const Text('View errors, performance, and health'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MonitoringScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

              // About Section
              _SectionHeader(title: 'About'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.blue),
                      title: const Text('About App'),
                      subtitle: Text('Version $_appVersion'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showAboutDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.green),
                      title: const Text('Documentation'),
                      subtitle: const Text('View user guide'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.info_outline, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(child: Text('Documentation available in project files')),
                              ],
                            ),
                            backgroundColor: Colors.blue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        l10n.appTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Professional Credit Management',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية (Arabic)';
      case 'fr':
        return 'Français (French)';
      case 'tn':
        return 'الدارجة التونسية (Tunisian)';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> _showChangePinDialog(AuthProvider authProvider) async {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPinController,
                decoration: const InputDecoration(labelText: 'Current PIN'),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newPinController,
                decoration: const InputDecoration(labelText: 'New PIN (4-6 digits)'),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPinController,
                decoration: const InputDecoration(labelText: 'Confirm New PIN'),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
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
              if (oldPinController.text.isEmpty ||
                  newPinController.text.isEmpty ||
                  confirmPinController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New PINs do not match')),
                );
                return;
              }

              if (newPinController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be at least 4 digits')),
                );
                return;
              }

              try {
                final success = await authProvider.changePin(
                  oldPinController.text,
                  newPinController.text,
                );

                if (success) {
                  if (context.mounted) Navigator.pop(context, true);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Current PIN is incorrect'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN changed successfully')),
      );
    }
  }

  Future<void> _showAutoLockDialog(AuthProvider authProvider) async {
    int selectedTimeout = authProvider.autoLockTimeout;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Auto-Lock Timeout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select how long before the app locks automatically:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: selectedTimeout,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Timeout',
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 minute')),
                  DropdownMenuItem(value: 5, child: Text('5 minutes')),
                  DropdownMenuItem(value: 10, child: Text('10 minutes')),
                  DropdownMenuItem(value: 15, child: Text('15 minutes')),
                  DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  DropdownMenuItem(value: 60, child: Text('1 hour')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedTimeout = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedTimeout),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await authProvider.setAutoLockTimeout(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auto-lock set to $result minutes')),
        );
      }
    }
  }

  Future<void> _logout(AuthProvider authProvider) async {
    final confirmed = await ConfirmationDialog.showWarning(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
    );

    if (!confirmed || !mounted) return;

    await authProvider.logout();
    
    if (mounted) {
      // Navigate to login screen (handled by AuthWrapper)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _showLanguageDialog(LocalizationProvider localization) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.language, color: Colors.blue),
            SizedBox(width: 12),
            Text('Select Language'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              code: 'en',
              name: 'English',
              nativeName: 'English',
              isSelected: localization.languageCode == 'en',
              onTap: () {
                localization.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _LanguageOption(
              code: 'ar',
              name: 'Arabic',
              nativeName: 'العربية',
              isSelected: localization.languageCode == 'ar',
              onTap: () {
                localization.setLanguage('ar');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _LanguageOption(
              code: 'fr',
              name: 'French',
              nativeName: 'Français',
              isSelected: localization.languageCode == 'fr',
              onTap: () {
                localization.setLanguage('fr');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _LanguageOption(
              code: 'tn',
              name: 'Tunisian Arabic',
              nativeName: 'الدارجة التونسية',
              isSelected: localization.languageCode == 'tn',
              onTap: () {
                localization.setLanguage('tn');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Language option widget
class _LanguageOption extends StatelessWidget {
  final String code;
  final String name;
  final String nativeName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

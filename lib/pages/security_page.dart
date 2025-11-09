import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricsEnabled = false;
  bool _twoFactorEnabled = true;
  bool _suspiciousLoginAlerts = true;
  bool _autoLockEnabled = true;
  Duration _autoLockDuration = const Duration(minutes: 5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAccountStatus(theme),
          const SizedBox(height: 16),
          _buildAuthenticationSection(theme),
          const SizedBox(height: 16),
          _buildLockCard(theme),
          const SizedBox(height: 16),
          _buildAlertsSection(theme),
          const SizedBox(height: 16),
          _buildRecentLogins(theme),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
            label: const Text('Deactivate Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatus(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.verified_user, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Security posture: Strong', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'All recommended protections are active. Review recent activity below.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Security Checklist'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationSection(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.lock_open),
            title: const Text('Authentication'),
            subtitle: const Text('Manage sign-in methods and trusted devices'),
          ),
          SwitchListTile(
            value: _twoFactorEnabled,
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Require OTP via authenticator or SMS'),
            onChanged: (value) => setState(() => _twoFactorEnabled = value),
          ),
          SwitchListTile(
            value: _biometricsEnabled,
            title: const Text('Biometric Login'),
            subtitle: const Text('Use fingerprint or face ID on supported devices'),
            onChanged: (value) => setState(() => _biometricsEnabled = value),
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Reset Password'),
            subtitle: const Text('Last updated 42 days ago'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _handleResetPassword(context),
          ),
          const Divider(height: 0),
          // Trusted Devices section removed per request.
        ],
      ),
    );
  }

  Widget _buildLockCard(ThemeData theme) {
    final durations = const [
      Duration(minutes: 1),
      Duration(minutes: 5),
      Duration(minutes: 10),
      Duration(minutes: 30),
    ];

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            value: _autoLockEnabled,
            title: const Text('Auto-lock App'),
            subtitle: const Text('Lock after a period of inactivity'),
            onChanged: (value) => setState(() => _autoLockEnabled = value),
          ),
          if (_autoLockEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: DropdownButtonFormField<Duration>(
                initialValue: _autoLockDuration,
                decoration: const InputDecoration(labelText: 'Auto-lock after'),
                items: durations
                    .map(
                      (duration) => DropdownMenuItem(
                        value: duration,
                        child: Text('${duration.inMinutes} minutes'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _autoLockDuration = value);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Security Alerts'),
            subtitle: const Text('Get notified about risky activity'),
          ),
          SwitchListTile(
            value: _suspiciousLoginAlerts,
            title: const Text('Suspicious login alerts'),
            subtitle: const Text('Receive push and email notifications'),
            onChanged: (value) => setState(() => _suspiciousLoginAlerts = value),
          ),
          SwitchListTile(
            value: true,
            title: const Text('Weekly security digest'),
            subtitle: const Text('Summary of alerts and remediation actions'),
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogins(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Recent Sign-ins'),
            subtitle: const Text('Review the last devices that accessed your workspace'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ),
          // Recent sign-ins removed per request
        ],
      ),
    );
  }
}

extension on _SecurityPageState {
  void _handleResetPassword(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Send password reset email'),
              subtitle: const Text('We will email instructions to your registered address.'),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset email sent.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change password'),
              subtitle: const Text('Update your password now'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showChangePasswordDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  String next = '';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
          content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Current password'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter current password' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'New password'),
                obscureText: true,
                onChanged: (v) => next = v,
                validator: (v) {
                  if (v == null || v.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirm new password'),
                obscureText: true,
                validator: (v) => (v != next) ? 'Passwords do not match' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

// Recent sign-in model removed.

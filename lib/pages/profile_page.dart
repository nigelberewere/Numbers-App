import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import 'login_page_clean.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NumberFormat _currency = NumberFormat.simpleCurrency(name: 'USD');

  String _fullName = 'Nigel Berewere';
  String _email = 'nigel.berewere@numbersapp.io';
  String _businessName = 'Numbers Analytics Co.';
  String _industry = 'Financial Services';
  String _preferredCurrency = 'USD';

  bool _emailNotifications = true;
  bool _smsNotifications = false;

  double _monthlyRevenueTarget = 12000;
  double _monthlyExpenseCap = 4500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 16),
          _buildBusinessDetails(context),
          const SizedBox(height: 16),
          _buildNotificationSettings(context),
          
          _buildTargets(context),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              // Sign out via the auth service and take the user to the login screen.
              final navigator = Navigator.of(context);
              await authService.signOut();
              if (!mounted) return;
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CleanLoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                _fullName.isNotEmpty ? _fullName.characters.first : '?',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ProfileChip(
                        label: 'Business',
                        value: _businessName,
                        onTap: () => _editField('Business Name', _businessName, (value) {
                          setState(() {
                            _businessName = value;
                          });
                        }),
                      ),
                      _ProfileChip(
                        label: 'Industry',
                        value: _industry,
                        onTap: () => _editField('Industry', _industry, (value) {
                          setState(() {
                            _industry = value;
                          });
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editField('Full Name', _fullName, (value) {
                setState(() {
                  _fullName = value;
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetails(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Address'),
            subtitle: Text(_email),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editField('Email Address', _email, (value) {
              setState(() {
                _email = value;
              });
            }),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Preferred Currency'),
            subtitle: Text(_preferredCurrency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editField('Preferred Currency', _preferredCurrency, (value) {
              setState(() {
                _preferredCurrency = value.toUpperCase();
              });
            }),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Business Name'),
            subtitle: Text(_businessName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editField('Business Name', _businessName, (value) {
              setState(() {
                _businessName = value;
              });
            }),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Industry'),
            subtitle: Text(_industry),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editField('Industry', _industry, (value) {
              setState(() {
                _industry = value;
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Manage how you stay informed'),
          ),
          SwitchListTile(
            value: _emailNotifications,
            title: const Text('Email Alerts'),
            subtitle: const Text('Monthly statements, alerts and feature updates'),
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          SwitchListTile(
            value: _smsNotifications,
            title: const Text('SMS Notifications'),
            subtitle: const Text('Critical account activity only'),
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  

  Widget _buildTargets(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Monthly Targets'),
            subtitle: const Text('Track your progress against goals'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _TargetTile(
                  label: 'Revenue Target',
                  value: _currency.format(_monthlyRevenueTarget),
                  onTap: () => _editNumericField(
                    context,
                    title: 'Revenue Target',
                    initialValue: _monthlyRevenueTarget,
                    onChanged: (value) {
                      setState(() {
                        _monthlyRevenueTarget = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _TargetTile(
                  label: 'Expense Cap',
                  value: _currency.format(_monthlyExpenseCap),
                  onTap: () => _editNumericField(
                    context,
                    title: 'Expense Cap',
                    initialValue: _monthlyExpenseCap,
                    onChanged: (value) {
                      setState(() {
                        _monthlyExpenseCap = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editField(String title, String initialValue, ValueChanged<String> onChanged) {
    final controller = TextEditingController(text: initialValue);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: title,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onChanged(controller.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editNumericField(
    BuildContext context, {
    required String title,
    required double initialValue,
    required ValueChanged<double> onChanged,
  }) {
    final controller = TextEditingController(text: initialValue.toStringAsFixed(2));
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '\$',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.replaceAll(',', ''));
                if (value != null) {
                  onChanged(value);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ProfileChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      onPressed: onTap,
    );
  }
}

class _TargetTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TargetTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

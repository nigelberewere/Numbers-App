import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final NumberFormat _currency = NumberFormat.simpleCurrency(name: 'USD');

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userProfileAsync.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(context, profile),
            const SizedBox(height: 16),
            _buildBusinessDetails(context, profile),
            const SizedBox(height: 16),
            _buildNotificationSettings(context, profile),
            _buildTargets(context, profile),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await ref.read(authServiceProvider).signOut();
                if (!mounted) return;
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    final user = ref.watch(currentUserProvider);
    final fullName = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      fullName.isNotEmpty ? fullName.characters.first : '?',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ProfileChip(
                        label: 'Business',
                        value: profile.businessName.isNotEmpty
                            ? profile.businessName
                            : 'Enter Business Name',
                        isPlaceholder: profile.businessName.isEmpty,
                        onTap: () => _editField(
                          'Business Name',
                          profile.businessName,
                          (value) => _updateProfile(
                            profile.copyWith(businessName: value),
                          ),
                        ),
                      ),
                      _ProfileChip(
                        label: 'Industry',
                        value: profile.industry.isNotEmpty
                            ? profile.industry
                            : 'Select Industry',
                        isPlaceholder: profile.industry.isEmpty,
                        onTap: () => _editField(
                          'Industry',
                          profile.industry,
                          (value) =>
                              _updateProfile(profile.copyWith(industry: value)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetails(BuildContext context, UserProfile profile) {
    final user = ref.watch(currentUserProvider);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Address'),
            subtitle: Text(user?.email ?? ''),
            // Email is managed by Auth, not editable here easily without re-auth
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Preferred Currency'),
            subtitle: Text(profile.preferredCurrency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editField(
              'Preferred Currency',
              profile.preferredCurrency,
              (value) => _updateProfile(
                profile.copyWith(preferredCurrency: value.toUpperCase()),
              ),
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Business Name'),
            subtitle: Text(
              profile.businessName.isNotEmpty
                  ? profile.businessName
                  : 'Enter Business Name',
              style: profile.businessName.isEmpty
                  ? const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    )
                  : null,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editField(
              'Business Name',
              profile.businessName,
              (value) => _updateProfile(profile.copyWith(businessName: value)),
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Industry'),
            subtitle: Text(
              profile.industry.isNotEmpty
                  ? profile.industry
                  : 'Select Industry',
              style: profile.industry.isEmpty
                  ? const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    )
                  : null,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editField(
              'Industry',
              profile.industry,
              (value) => _updateProfile(profile.copyWith(industry: value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context, UserProfile profile) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Manage how you stay informed'),
          ),
          SwitchListTile(
            value: profile.emailNotifications,
            title: const Text('Email Alerts'),
            subtitle: const Text(
              'Monthly statements, alerts and feature updates',
            ),
            onChanged: (value) =>
                _updateProfile(profile.copyWith(emailNotifications: value)),
          ),
          SwitchListTile(
            value: profile.smsNotifications,
            title: const Text('SMS Notifications'),
            subtitle: const Text('Critical account activity only'),
            onChanged: (value) =>
                _updateProfile(profile.copyWith(smsNotifications: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildTargets(BuildContext context, UserProfile profile) {
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
                  value: profile.monthlyRevenueTarget > 0
                      ? _currency.format(profile.monthlyRevenueTarget)
                      : 'Set Target',
                  isPlaceholder: profile.monthlyRevenueTarget == 0,
                  onTap: () => _editNumericField(
                    context,
                    title: 'Revenue Target',
                    initialValue: profile.monthlyRevenueTarget,
                    onChanged: (value) => _updateProfile(
                      profile.copyWith(monthlyRevenueTarget: value),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _TargetTile(
                  label: 'Expense Cap',
                  value: profile.monthlyExpenseCap > 0
                      ? _currency.format(profile.monthlyExpenseCap)
                      : 'Set Cap',
                  isPlaceholder: profile.monthlyExpenseCap == 0,
                  onTap: () => _editNumericField(
                    context,
                    title: 'Expense Cap',
                    initialValue: profile.monthlyExpenseCap,
                    onChanged: (value) => _updateProfile(
                      profile.copyWith(monthlyExpenseCap: value),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(UserProfile updatedProfile) async {
    try {
      await ref.read(userRepositoryProvider).updateUserProfile(updatedProfile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  void _editField(
    String title,
    String initialValue,
    ValueChanged<String> onChanged,
  ) {
    final controller = TextEditingController(text: initialValue);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: title),
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
    final controller = TextEditingController(
      text: initialValue > 0 ? initialValue.toStringAsFixed(2) : '',
    );
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '\$'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text.replaceAll(',', ''),
                );
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
  final bool isPlaceholder;

  const _ProfileChip({
    required this.label,
    required this.value,
    required this.onTap,
    this.isPlaceholder = false,
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
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isPlaceholder ? Colors.grey : null,
              fontStyle: isPlaceholder ? FontStyle.italic : null,
            ),
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
  final bool isPlaceholder;

  const _TargetTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.isPlaceholder = false,
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
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isPlaceholder ? Colors.grey : null,
                    fontStyle: isPlaceholder ? FontStyle.italic : null,
                  ),
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

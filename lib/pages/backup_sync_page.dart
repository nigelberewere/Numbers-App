import 'package:flutter/material.dart';

class BackupSyncPage extends StatefulWidget {
  const BackupSyncPage({super.key});

  @override
  State<BackupSyncPage> createState() => _BackupSyncPageState();
}

class _BackupSyncPageState extends State<BackupSyncPage> {
  bool _autoBackup = true;
  bool _wifiOnly = true;
  bool _backgroundSync = false;
  String _selectedSchedule = 'Daily';
  DateTime? _lastBackup = DateTime.now().subtract(const Duration(hours: 6));

  final List<String> _schedules = const ['Hourly', 'Daily', 'Weekly'];
  // Linked devices removed per request.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(theme),
          const SizedBox(height: 16),
          _buildToggleCard(theme),
          const SizedBox(height: 16),
          _buildScheduleCard(theme),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _handleBackupNow,
            child: const Text('Back Up Now'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _handleSyncAudit,
            child: const Text('View Sync History'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final lastBackup = _lastBackup;
    final subtitle = lastBackup != null
        ? 'Last backup ${_formatRelative(lastBackup)}'
        : 'No backups completed yet';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.cloud_done, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud backup active',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'We keep the last 30 backups securely encrypted. Manual backups remain available on this device for seven days.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            value: _autoBackup,
            title: const Text('Automatic Backups'),
            subtitle: const Text('Run incremental backups in the background'),
            onChanged: (value) => setState(() => _autoBackup = value),
          ),
          SwitchListTile(
            value: _wifiOnly,
            title: const Text('Wi-Fi Only'),
            subtitle: const Text('Prevent large uploads on mobile data'),
            onChanged: (value) => setState(() => _wifiOnly = value),
          ),
          SwitchListTile(
            value: _backgroundSync,
            title: const Text('Background Sync'),
            subtitle: const Text('Apply changes from other devices automatically'),
            onChanged: (value) => setState(() => _backgroundSync = value),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Backup Frequency'),
            subtitle: const Text('Choose how often to capture full snapshots'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSchedule,
              decoration: const InputDecoration(labelText: 'Schedule'),
              items: _schedules
                  .map((schedule) => DropdownMenuItem(
                        value: schedule,
                        child: Text(schedule),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedSchedule = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Linked Devices UI removed.

  void _handleBackupNow() {
    setState(() => _lastBackup = DateTime.now());
    _showSnackBar('Backup complete. All records are up to date.');
  }

  void _handleSyncAudit() {
    _showSnackBar('Sync history exported to your device.');
  }

  // Disconnect handler removed (linked devices removed).

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatRelative(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}

// Connected device model removed.

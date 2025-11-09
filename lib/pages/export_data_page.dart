import 'package:flutter/material.dart';

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  final Set<_ExportFormat> _selectedFormats = {_ExportFormat.pdf};
  bool _includeAttachments = true;
  bool _includeAnalytics = true;
  bool _maskSensitiveFields = true;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(theme),
          const SizedBox(height: 16),
          _buildFormatCard(theme),
          const SizedBox(height: 16),
          _buildFiltersCard(theme),
          const SizedBox(height: 16),
          _buildDeliveryCard(theme),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _selectedFormats.isEmpty ? null : _handleExport,
            icon: const Icon(Icons.outbox),
            label: const Text('Generate Export'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _handleAutomation,
            child: const Text('Set Up Automated Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
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
                  child: Icon(Icons.download_done, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Export your workspace', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Create local copies of transactions, inventory, and analytics snapshots.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Exports are encrypted with your account key. You can optionally share the export link with collaborators for 48 hours.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.file_present),
            title: const Text('File Formats'),
            subtitle: const Text('Select one or more export packages'),
          ),
          const Divider(height: 0),
          ..._ExportFormat.values.map((format) {
            final selected = _selectedFormats.contains(format);
            return CheckboxListTile(
              value: selected,
              title: Text(format.label),
              subtitle: Text(format.description),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedFormats.add(format);
                  } else {
                    _selectedFormats.remove(format);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(ThemeData theme) {
    final dateLabel = _dateRange == null
        ? 'All time'
        : '${_dateRange!.start.toLocal().toString().split(' ').first} → ${_dateRange!.end.toLocal().toString().split(' ').first}';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Filters'),
            subtitle: const Text('Limit what gets bundled into the export'),
          ),
          SwitchListTile(
            value: _includeAttachments,
            title: const Text('Include Attachments'),
            subtitle: const Text('Receipts, invoices, and supporting documents'),
            onChanged: (value) => setState(() => _includeAttachments = value),
          ),
          SwitchListTile(
            value: _includeAnalytics,
            title: const Text('Include Analytics Models'),
            subtitle: const Text('Balance sheet snapshots and derived metrics'),
            onChanged: (value) => setState(() => _includeAnalytics = value),
          ),
          SwitchListTile(
            value: _maskSensitiveFields,
            title: const Text('Mask Sensitive Data'),
            subtitle: const Text('Hide customer PII and banking details'),
            onChanged: (value) => setState(() => _maskSensitiveFields = value),
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Date Range'),
            subtitle: Text(dateLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDateRange,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_queue),
            title: const Text('Delivery Options'),
            subtitle: const Text('Exports stay available online for 48 hours'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(Icons.link, color: theme.colorScheme.secondary),
            ),
            title: const Text('Download Link'),
            subtitle: const Text('Generate a shareable link with optional password'),
            trailing: TextButton(
              onPressed: () => _showSnackBar('Download link copied to clipboard.'),
              child: const Text('Copy'),
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.tertiaryContainer,
              child: Icon(Icons.email_outlined, color: theme.colorScheme.tertiary),
            ),
            title: const Text('Email Delivery'),
            subtitle: const Text('Send directly to verified collaborators'),
            trailing: TextButton(
              onPressed: () => _showSnackBar('Email notifications scheduled.'),
              child: const Text('Manage'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (result != null && mounted) {
      setState(() => _dateRange = result);
    }
  }

  void _handleExport() {
    final formats = _selectedFormats.map((format) => format.label).join(', ');
    final dateRange = _dateRange == null ? 'all time' : 'selected dates';
    final analytics = _includeAnalytics ? 'analytics' : 'no analytics';
    _showSnackBar('Export queued ($formats • $dateRange • $analytics).');
  }

  void _handleAutomation() {
    _showSnackBar('Recurring export wizard coming soon.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _ExportFormat {
  pdf('PDF Summary', 'Great for quick overviews and stakeholder reports'),
  csv('CSV (Transactions)', 'Compatible with spreadsheets and BI tooling'),
  xlsx('Excel Workbook', 'Separate sheets for transactions, accounts, and analytics'),
  json('JSON Archive', 'Machine-readable bundle for integrations and backups');

  final String label;
  final String description;

  const _ExportFormat(this.label, this.description);
}

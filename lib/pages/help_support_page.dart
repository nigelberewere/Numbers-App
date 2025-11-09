import 'package:flutter/material.dart';
// package_info_plus removed — Release Notes/Status removed

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContactCard(theme),
          const SizedBox(height: 16),
          _buildFaqCard(theme),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ThemeData theme) {
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
                  child: Icon(Icons.support_agent, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need human help?', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Our team is available weekdays 8am-8pm and Saturdays 10am-4pm.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat with us'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email support'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('+263 780 507 162'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildFaqCard(ThemeData theme) {
    final faqs = const [
      _FaqItem('How do I export statements?', 'Head to Settings → Export Data to generate PDF, CSV, or Excel reports.'),
      _FaqItem('Can I restore backups?', 'Yes. Visit Settings → Backup & Sync to download the latest snapshot.'),
      _FaqItem('Does Numbers work offline?', 'You can record transactions offline. Sync resumes automatically once online.'),
    ];

    return Card(
      child: ExpansionPanelList.radio(
        expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
        children: faqs
            .map(
              (faq) => ExpansionPanelRadio(
                value: faq.question,
                headerBuilder: (context, isExpanded) => ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(faq.question),
                ),
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(faq.answer),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  
}

 

 

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem(this.question, this.answer);
}

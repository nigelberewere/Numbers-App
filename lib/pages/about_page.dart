import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Map<String, String> _teamMembers = {
    'Nigel Berewere': '',
    'Dennis Mademutsa': '',
    'Tadaishe Chibondo': '',
  };

  static final Uri _websiteUri = Uri.parse('https://numbersapp.io');
  static final Uri _privacyUri = Uri.parse(
    'https://numbersapp.io/legal/privacy',
  );
  static final Uri _termsUri = Uri.parse('https://numbersapp.io/legal/terms');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Numbers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(theme),
          const SizedBox(height: 16),
          _buildMissionCard(theme),
          const SizedBox(height: 16),
          _buildTeamCard(theme),
          const SizedBox(height: 16),
          _buildVersionCard(theme),
          const SizedBox(height: 16),
          _buildLegalCard(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              // Use a contained image so it doesn't get cropped by the CircleAvatar
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SvgPicture.asset(
                    'lib/assets/icon/icon.svg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Numbers',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Financial intelligence for growth-focused businesses across Africa.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _launch(_websiteUri),
                        icon: const Icon(Icons.public),
                        label: const Text('Visit Website'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _launch(Uri.parse('mailto:hello@numbersapp.io')),
                        icon: const Icon(Icons.mail_outline),
                        label: const Text('Contact'),
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

  Widget _buildMissionCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our Mission', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Numbers helps entrepreneurs track cashflow, understand profitability, and prepare investor-ready reports without an accounting degree.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Across Africa, growing businesses rely on Numbers for powerful analytics, automated insights, and simple process automation.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Meet the Team'),
            subtitle: const Text(
              'We are a distributed team with roots in Zimbabwe.',
            ),
          ),
          ..._teamMembers.entries.map(
            (entry) => Column(
              children: [
                const Divider(height: 0),
                ListTile(
                  leading: CircleAvatar(
                    child: Text(entry.key.characters.first),
                  ),
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Release Info'),
            subtitle: const Text(
              'Stay up to date with the latest improvements',
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.system_update_alt,
                color: theme.colorScheme.secondary,
              ),
            ),
            title: const Text('App Version'),
            subtitle: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Unknown');
                }
                final info = snapshot.data!;
                return Text('${info.version} (build ${info.buildNumber})');
              },
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.tertiaryContainer,
              child: Icon(
                Icons.schedule_outlined,
                color: theme.colorScheme.tertiary,
              ),
            ),
            title: const Text('Last Updated'),
            subtitle: const Text('November 1, 2025'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalCard(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Legal & Licenses'),
            subtitle: const Text('Transparency about how we protect you'),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launch(_privacyUri),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launch(_termsUri),
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }

  static Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }
}

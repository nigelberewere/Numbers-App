import 'package:flutter/material.dart';
import 'animal_husbandry_page.dart';
import 'crop_production_page.dart';
import 'horticulture_page.dart';

class AgriculturePage extends StatelessWidget {
  const AgriculturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Agriculture Type',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your area of focus',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AgricultureCard(
            icon: Icons.pets,
            title: 'Animal Husbandry',
            description: 'Livestock management, breeding, feed tracking',
            color: Colors.brown,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AnimalHusbandryPage(),
              ));
            },
          ),
          _AgricultureCard(
            icon: Icons.grass,
            title: 'Crop Production',
            description: 'Planting, input costs, harvest yields',
            color: Colors.green,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CropProductionPage(),
              ));
            },
          ),
          _AgricultureCard(
            icon: Icons.local_florist,
            title: 'Horticulture',
            description: 'Nursery management, sales, input tracking',
            color: Colors.pink,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const HorticulturePage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _AgricultureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _AgricultureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

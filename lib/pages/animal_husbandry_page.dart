import 'package:flutter/material.dart';

class Animal {
  final String id;
  String name;
  String species;
  DateTime dob;
  double weightKg;
  String notes;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.dob,
    required this.weightKg,
    this.notes = '',
  });
}

class AnimalHusbandryPage extends StatefulWidget {
  const AnimalHusbandryPage({super.key});

  @override
  State<AnimalHusbandryPage> createState() => _AnimalHusbandryPageState();
}

class _AnimalHusbandryPageState extends State<AnimalHusbandryPage> {
  final List<Animal> _animals = [];

  String _ageString(DateTime dob) {
  final now = DateTime.now();
  final years = now.year - dob.year - ((now.month < dob.month || (now.month == dob.month && now.day < dob.day)) ? 1 : 0);
  final months = (now.month - dob.month - (now.day < dob.day ? 1 : 0)) % 12;
  if (years > 0) return '$years y $months m';
  if (months > 0) return '$months m';
    final days = now.difference(dob).inDays;
    return '$days d';
  }

  Future<Animal?> _showAnimalDialog({Animal? initial}) async {
    final nameCtrl = TextEditingController(text: initial?.name ?? '');
    final speciesCtrl = TextEditingController(text: initial?.species ?? '');
    final weightCtrl = TextEditingController(text: initial != null ? initial.weightKg.toStringAsFixed(2) : '');
    final notesCtrl = TextEditingController(text: initial?.notes ?? '');
    DateTime dob = initial?.dob ?? DateTime.now();

    final result = await showDialog<Animal>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDlgState) {
          return AlertDialog(
            title: Text(initial == null ? 'Add Animal' : 'Edit Animal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: speciesCtrl,
                    decoration: const InputDecoration(labelText: 'Species'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: dob,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDlgState(() => dob = picked);
                            }
                          },
                          child: Text('DOB: ${dob.toLocal()}'.split(' ')[0]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Weight kg'),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final species = speciesCtrl.text.trim();
                  final weight = double.tryParse(weightCtrl.text.replaceAll(',', '')) ?? 0.0;
                  if (name.isEmpty || species.isEmpty) return;
                  final animal = Animal(
                    id: initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    species: species,
                    dob: dob,
                    weightKg: weight,
                    notes: notesCtrl.text.trim(),
                  );
                  Navigator.of(context).pop(animal);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );

    return result;
  }

  void _addAnimal() async {
    final animal = await _showAnimalDialog();
    if (!mounted) return;
    if (animal != null) {
      setState(() {
        _animals.insert(0, animal);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Animal added')));
    }
  }

  void _editAnimal(Animal a) async {
    final updated = await _showAnimalDialog(initial: a);
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        final idx = _animals.indexWhere((e) => e.id == a.id);
        if (idx != -1) _animals[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Animal updated')));
    }
  }

  void _deleteAnimal(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Animal'),
        content: const Text('Remove this animal from records?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      setState(() {
        _animals.removeWhere((e) => e.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Animal removed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Husbandry'),
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
                    'Livestock Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add and track animals, breeding cycles, feed schedules and costs.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addAnimal,
            icon: const Icon(Icons.add),
            label: const Text('Add Animal'),
          ),
          const SizedBox(height: 12),
          if (_animals.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.pets, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No animals added yet', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else ..._animals.map((a) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(a.name.isNotEmpty ? a.name[0] : '?')),
                  title: Text('${a.name} • ${a.species}'),
                  subtitle: Text('Age: ${_ageString(a.dob)} • ${a.weightKg.toStringAsFixed(1)} kg'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _editAnimal(a);
                      if (v == 'delete') _deleteAnimal(a.id);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(a.name),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Species: ${a.species}'),
                          const SizedBox(height: 6),
                          Text('DOB: ${a.dob.toLocal()}'.split(' ')[0]),
                          const SizedBox(height: 6),
                          Text('Weight: ${a.weightKg.toStringAsFixed(2)} kg'),
                          const SizedBox(height: 6),
                          if (a.notes.isNotEmpty) Text('Notes: ${a.notes}'),
                        ],
                      ),
                      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

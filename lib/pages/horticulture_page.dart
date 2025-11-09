import 'package:flutter/material.dart';

class PlantItem {
  final String id;
  String name;
  String species;
  int quantity;
  double unitPrice; // per plant
  DateTime dateAdded;
  String notes;
  List<SaleRecord> sales;
  List<PropagationRecord> propagations;

  PlantItem({
    required this.id,
    required this.name,
    required this.species,
    required this.quantity,
    required this.unitPrice,
    required this.dateAdded,
    this.notes = '',
    List<SaleRecord>? sales,
    List<PropagationRecord>? propagations,
  })  : sales = sales ?? [],
        propagations = propagations ?? [];
}

class SaleRecord {
  final String id;
  int quantity;
  double pricePerUnit;
  DateTime date;
  String notes;

  SaleRecord({required this.id, required this.quantity, required this.pricePerUnit, required this.date, this.notes = ''});
}

class PropagationRecord {
  final String id;
  int quantityAdded;
  DateTime date;
  String notes;

  PropagationRecord({required this.id, required this.quantityAdded, required this.date, this.notes = ''});
}

class HorticulturePage extends StatefulWidget {
  const HorticulturePage({super.key});

  @override
  State<HorticulturePage> createState() => _HorticulturePageState();
}

class _HorticulturePageState extends State<HorticulturePage> {
  final List<PlantItem> _plants = [];

  Future<PlantItem?> _showPlantDialog({PlantItem? initial}) async {
    final nameCtrl = TextEditingController(text: initial?.name ?? '');
    final speciesCtrl = TextEditingController(text: initial?.species ?? '');
    final qtyCtrl = TextEditingController(text: initial != null ? initial.quantity.toString() : '');
    final priceCtrl = TextEditingController(text: initial != null ? initial.unitPrice.toStringAsFixed(2) : '');
    final notesCtrl = TextEditingController(text: initial?.notes ?? '');
    DateTime dateAdded = initial?.dateAdded ?? DateTime.now();

    final result = await showDialog<PlantItem>(context: context, builder: (context) {
      return StatefulBuilder(builder: (context, setStateDlg) {
        return AlertDialog(
          title: Text(initial == null ? 'Add Plant' : 'Edit Plant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: speciesCtrl, decoration: const InputDecoration(labelText: 'Species')),
                Row(children: [
                  Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'))),
                  const SizedBox(width: 8),
                  SizedBox(width: 140, child: TextField(controller: priceCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Unit price'))),
                ]),
                TextButton(onPressed: () async {
                  final picked = await showDatePicker(context: context, initialDate: dateAdded, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 3650)));
                  if (picked != null) setStateDlg(() => dateAdded = picked);
                }, child: Text('Added: ${dateAdded.toLocal()}'.split(' ')[0])),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(onPressed: () {
              final name = nameCtrl.text.trim();
              final species = speciesCtrl.text.trim();
              final qty = int.tryParse(qtyCtrl.text.replaceAll(',', '')) ?? 0;
              final price = double.tryParse(priceCtrl.text.replaceAll(',', '')) ?? 0.0;
              if (name.isEmpty || species.isEmpty) {
                return;
              }
              final item = PlantItem(
                id: initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                species: species,
                quantity: qty,
                unitPrice: price,
                dateAdded: dateAdded,
                notes: notesCtrl.text.trim(),
              );
              Navigator.of(context).pop(item);
            }, child: const Text('Save')),
          ],
        );
      });
    });

    return result;
  }

  void _addPlant() async {
    final plant = await _showPlantDialog();
    if (!mounted) {
      return;
    }
    if (plant != null) {
      setState(() => _plants.insert(0, plant));
    }
  }

  void _editPlant(PlantItem p) async {
    final updated = await _showPlantDialog(initial: p);
    if (!mounted) {
      return;
    }
    if (updated != null) {
      setState(() {
        final idx = _plants.indexWhere((e) => e.id == p.id);
        if (idx != -1) _plants[idx] = updated;
      });
    }
  }

  void _deletePlant(String id) async {
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete plant'), content: const Text('Remove this plant from inventory?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Delete'))]));
    if (!mounted) {
      return;
    }
    if (confirmed == true) setState(() => _plants.removeWhere((p) => p.id == id));
  }

  Future<SaleRecord?> _showAddSaleDialog(PlantItem p) async {
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: p.unitPrice.toStringAsFixed(2));
    final notesCtrl = TextEditingController();
    DateTime date = DateTime.now();

    final res = await showDialog<SaleRecord>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Record Sale'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity sold')),
              TextField(controller: priceCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price per unit')),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 3650)));
                  if (picked != null) date = picked;
                },
                child: Text('Date: ${date.toLocal()}'.split(' ')[0]),
              ),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final qty = int.tryParse(qtyCtrl.text.replaceAll(',', '')) ?? 0;
            final price = double.tryParse(priceCtrl.text.replaceAll(',', '')) ?? p.unitPrice;
            if (qty <= 0) return;
            final rec = SaleRecord(id: DateTime.now().millisecondsSinceEpoch.toString(), quantity: qty, pricePerUnit: price, date: date, notes: notesCtrl.text.trim());
            Navigator.of(c).pop(rec);
          }, child: const Text('Add')),
        ],
      ),
    );

    return res;
  }

  Future<PropagationRecord?> _showPropagationDialog(PlantItem p) async {
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime date = DateTime.now();

    final res = await showDialog<PropagationRecord>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Record Propagation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity added')),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 3650)));
                  if (picked != null) date = picked;
                },
                child: Text('Date: ${date.toLocal()}'.split(' ')[0]),
              ),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final qty = int.tryParse(qtyCtrl.text.replaceAll(',', '')) ?? 0;
            if (qty <= 0) return;
            final rec = PropagationRecord(id: DateTime.now().millisecondsSinceEpoch.toString(), quantityAdded: qty, date: date, notes: notesCtrl.text.trim());
            Navigator.of(c).pop(rec);
          }, child: const Text('Add')),
        ],
      ),
    );

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horticulture')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nursery & Sales', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), const Text('Manage plant inventories, sales, propagation schedules and inputs.'), const SizedBox(height: 8), Text('Total inventory: ${_plants.fold<int>(0, (p, e) => p + e.quantity)} plants')]))),
        const SizedBox(height: 12),
        ElevatedButton.icon(onPressed: _addPlant, icon: const Icon(Icons.add), label: const Text('Add Plant')),
        const SizedBox(height: 12),
        if (_plants.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Column(children: [Icon(Icons.local_florist, size: 48, color: Colors.grey), SizedBox(height: 12), Text('No plants in inventory', style: TextStyle(color: Colors.grey))]))))
        else ..._plants.map((p) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(p.name.isNotEmpty ? p.name[0] : '?')),
              title: Text('${p.name} • ${p.species}'),
              subtitle: Text('Qty: ${p.quantity} • Price: ${p.unitPrice.toStringAsFixed(2)}'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    _editPlant(p);
                  }
                  if (v == 'delete') {
                    _deletePlant(p.id);
                  }
                  if (v == 'sale') {
                    final rec = await _showAddSaleDialog(p);
                    if (!mounted) {
                      return;
                    }
                    if (rec != null) {
                      setState(() {
                        p.sales.insert(0, rec);
                        p.quantity = (p.quantity - rec.quantity).clamp(0, 999999);
                      });
                    }
                  }
                  if (v == 'prop') {
                    final rec = await _showPropagationDialog(p);
                    if (!mounted) {
                      return;
                    }
                    if (rec != null) {
                      setState(() {
                        p.propagations.insert(0, rec);
                        p.quantity += rec.quantityAdded;
                      });
                    }
                  }
                },
                itemBuilder: (c) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'sale', child: Text('Record sale')),
                  const PopupMenuItem(value: 'prop', child: Text('Record propagation')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              onTap: () => showDialog<void>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(p.name),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Species: ${p.species}'),
                        const SizedBox(height: 6),
                        Text('Quantity: ${p.quantity}'),
                        const SizedBox(height: 6),
                        Text('Unit price: ${p.unitPrice.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        if (p.notes.isNotEmpty) Text('Notes: ${p.notes}'),
                        const Divider(),
                        const Text('Sales', style: TextStyle(fontWeight: FontWeight.w600)),
                        if (p.sales.isEmpty) ...[
                          const Text('No sales recorded', style: TextStyle(color: Colors.grey)),
                        ] else ...p.sales.map((s) => ListTile(dense: true, title: Text('${s.quantity} @ ${s.pricePerUnit.toStringAsFixed(2)}'), subtitle: Text('${s.date.toLocal()}'.split(' ')[0] + (s.notes.isNotEmpty ? ' • ${s.notes}' : '')))),
                        const Divider(),
                        const Text('Propagations', style: TextStyle(fontWeight: FontWeight.w600)),
                        if (p.propagations.isEmpty) ...[
                          const Text('No propagations', style: TextStyle(color: Colors.grey)),
                        ] else ...p.propagations.map((pr) => ListTile(dense: true, title: Text('+${pr.quantityAdded}'), subtitle: Text('${pr.date.toLocal()}'.split(' ')[0] + (pr.notes.isNotEmpty ? ' • ${pr.notes}' : '')))),
                        const Divider(),
                        Text('Total revenue: ${p.sales.fold<double>(0, (prev, s) => prev + (s.quantity * s.pricePerUnit)).toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Close'))],
                ),
              ),
            ),
          );
        }),
      ],
      ),
    );
  }
}

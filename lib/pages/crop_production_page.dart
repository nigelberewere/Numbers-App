import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FieldPlot {
  final String id;
  String name;
  String crop;
  double areaHa;
  DateTime plantingDate;
  double expectedYield; // in tonnes
  String notes;
  List<InputRecord> inputs;
  List<YieldRecord> yields;

  FieldPlot({
    required this.id,
    required this.name,
    required this.crop,
    required this.areaHa,
    required this.plantingDate,
    required this.expectedYield,
    this.notes = '',
    List<InputRecord>? inputs,
    List<YieldRecord>? yields,
  }) :
        inputs = inputs ?? [],
        yields = yields ?? [];
}

class InputRecord {
  final String id;
  String type; // e.g., Fertilizer, Seed, Water
  double amount; // units depend on type (kg, L, etc.)
  DateTime date;
  String notes;

  InputRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.notes = '',
  });
}

class YieldRecord {
  final String id;
  double quantity; // tonnes
  DateTime date;
  String notes;

  YieldRecord({
    required this.id,
    required this.quantity,
    required this.date,
    this.notes = '',
  });
}

class CropProductionPage extends StatefulWidget {
  const CropProductionPage({super.key});

  @override
  State<CropProductionPage> createState() => _CropProductionPageState();
}

class _CropProductionPageState extends State<CropProductionPage> {
  final List<FieldPlot> _fields = [];

  Future<FieldPlot?> _showFieldDialog({FieldPlot? initial}) async {
    final nameCtrl = TextEditingController(text: initial?.name ?? '');
    final cropCtrl = TextEditingController(text: initial?.crop ?? '');
    final areaCtrl = TextEditingController(text: initial != null ? initial.areaHa.toStringAsFixed(2) : '');
    final yieldCtrl = TextEditingController(text: initial != null ? initial.expectedYield.toStringAsFixed(2) : '');
    final notesCtrl = TextEditingController(text: initial?.notes ?? '');
    DateTime planting = initial?.plantingDate ?? DateTime.now();

    final result = await showDialog<FieldPlot>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDlgState) {
          return AlertDialog(
            title: Text(initial == null ? 'Plan Field' : 'Edit Field'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Field name')),
                  TextField(controller: cropCtrl, decoration: const InputDecoration(labelText: 'Crop')),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: planting,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) setDlgState(() => planting = picked);
                          },
                          child: Text('Planting: ${planting.toLocal()}'.split(' ')[0]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: areaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Area (ha)'),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: yieldCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Expected yield (t)'),
                  ),
                  TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final crop = cropCtrl.text.trim();
                  final area = double.tryParse(areaCtrl.text.replaceAll(',', '')) ?? 0.0;
                  final expYield = double.tryParse(yieldCtrl.text.replaceAll(',', '')) ?? 0.0;
                  if (name.isEmpty || crop.isEmpty) return;
                  final field = FieldPlot(
                    id: initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    crop: crop,
                    areaHa: area,
                    plantingDate: planting,
                    expectedYield: expYield,
                    notes: notesCtrl.text.trim(),
                  );
                  Navigator.of(context).pop(field);
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

  void _addField() async {
    final field = await _showFieldDialog();
    if (!mounted) return;
    if (field != null) {
      setState(() => _fields.insert(0, field));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Field planned')));
    }
  }

  void _editField(FieldPlot f) async {
    final updated = await _showFieldDialog(initial: f);
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        final idx = _fields.indexWhere((e) => e.id == f.id);
        if (idx != -1) _fields[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Field updated')));
    }
  }

  void _deleteField(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Field'),
        content: const Text('Remove this field?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      setState(() => _fields.removeWhere((e) => e.id == id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Field removed')));
    }
  }

  Future<InputRecord?> _showAddInputDialog(FieldPlot field) async {
    final typeCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime date = DateTime.now();

    final res = await showDialog<InputRecord>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Input'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type (e.g., Fertilizer)')),
              TextField(controller: amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount')),
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final type = typeCtrl.text.trim();
              final amount = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0.0;
              if (type.isEmpty) return;
              final rec = InputRecord(id: DateTime.now().millisecondsSinceEpoch.toString(), type: type, amount: amount, date: date, notes: notesCtrl.text.trim());
              Navigator.of(context).pop(rec);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    return res;
  }

  Future<YieldRecord?> _showAddYieldDialog(FieldPlot field) async {
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime date = DateTime.now();

    final res = await showDialog<YieldRecord>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Yield'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: qtyCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantity (t)')),
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final qty = double.tryParse(qtyCtrl.text.replaceAll(',', '')) ?? 0.0;
              final rec = YieldRecord(id: DateTime.now().millisecondsSinceEpoch.toString(), quantity: qty, date: date, notes: notesCtrl.text.trim());
              Navigator.of(context).pop(rec);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    return res;
  }

  void _deleteInput(FieldPlot field, InputRecord rec) async {
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Remove input'), content: const Text('Remove this input record?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Remove'))]));
    if (!mounted) return;
    if (confirmed == true) {
      setState(() => field.inputs.removeWhere((i) => i.id == rec.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Input removed')));
    }
  }

  void _deleteYield(FieldPlot field, YieldRecord rec) async {
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Remove yield'), content: const Text('Remove this yield record?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Remove'))]));
    if (!mounted) return;
    if (confirmed == true) {
      setState(() => field.yields.removeWhere((y) => y.id == rec.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yield removed')));
    }
  }

  Future<void> _exportFieldCSV(FieldPlot f) async {
    try {
      final rows = <List<dynamic>>[];
      rows.add(['Field ID', 'Name', 'Crop', 'Area (ha)', 'Planting Date', 'Expected Yield (t)', 'Notes']);
      rows.add([
        f.id,
        f.name,
        f.crop,
        f.areaHa.toStringAsFixed(2),
        f.plantingDate.toIso8601String(),
        f.expectedYield.toStringAsFixed(2),
        f.notes,
      ]);

      // Add Inputs section
      if (f.inputs.isNotEmpty) {
        rows.add([]);
        rows.add(['Inputs: id', 'Type', 'Amount', 'Date', 'Notes']);
        for (final i in f.inputs) {
          rows.add([i.id, i.type, i.amount.toStringAsFixed(2), i.date.toIso8601String(), i.notes]);
        }
      }

      // Add Yields section
      if (f.yields.isNotEmpty) {
        rows.add([]);
        rows.add(['Yields: id', 'Quantity (t)', 'Date', 'Notes']);
        for (final y in f.yields) {
          rows.add([y.id, y.quantity.toStringAsFixed(3), y.date.toIso8601String(), y.notes]);
        }
      }

      final csv = const ListToCsvConverter().convert(rows);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/field_${f.id}.csv');
      await file.writeAsString(csv);

  await Share.shareXFiles([XFile(file.path)], text: 'Exported field: ${f.name}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Production'),
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
                  Text('Field & Crop Management', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Track planting dates, inputs, yields and profitability per field.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _addField, icon: const Icon(Icons.grass), label: const Text('Plan Field')),
          const SizedBox(height: 12),
          if (_fields.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.grass, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No fields planned yet', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else ..._fields.map((f) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(f.crop.isNotEmpty ? f.crop[0] : '?')),
                  title: Text('${f.name} • ${f.crop}'),
                  subtitle: Text('Area: ${f.areaHa.toStringAsFixed(2)} ha • Planted: ${f.plantingDate.toLocal()}'.split(' ')[0]),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _editField(f);
                      if (v == 'delete') _deleteField(f.id);
                      if (v == 'export') _exportFieldCSV(f);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'export', child: Text('Export')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(f.name),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Crop: ${f.crop}'),
                            const SizedBox(height: 6),
                            Text('Area: ${f.areaHa.toStringAsFixed(2)} ha'),
                            const SizedBox(height: 6),
                            Text('Expected yield: ${f.expectedYield.toStringAsFixed(2)} t'),
                            const SizedBox(height: 6),
                            Text('Planted on: ${f.plantingDate.toLocal()}'.split(' ')[0]),
                            const SizedBox(height: 8),
                            if (f.notes.isNotEmpty) Text('Notes: ${f.notes}'),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Inputs', style: TextStyle(fontWeight: FontWeight.w600)),
                                TextButton.icon(onPressed: () async {
                                  final rec = await _showAddInputDialog(f);
                                  if (!mounted) return;
                                  if (rec != null) setState(() => f.inputs.insert(0, rec));
                                }, icon: const Icon(Icons.add), label: const Text('Add'))
                              ],
                            ),
                            if (f.inputs.isEmpty) const Text('No inputs recorded', style: TextStyle(color: Colors.grey))
                            else ...f.inputs.map((i) => ListTile(
                                  dense: true,
                                  title: Text('${i.type} • ${i.amount.toStringAsFixed(2)}'),
                                  subtitle: Text('${i.date.toLocal()}'.split(' ')[0] + (i.notes.isNotEmpty ? ' • ${i.notes}' : '')),
                                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteInput(f, i)),
                                )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Yields', style: TextStyle(fontWeight: FontWeight.w600)),
                                TextButton.icon(onPressed: () async {
                                  final rec = await _showAddYieldDialog(f);
                                  if (!mounted) return;
                                  if (rec != null) setState(() => f.yields.insert(0, rec));
                                }, icon: const Icon(Icons.add), label: const Text('Add'))
                              ],
                            ),
                            if (f.yields.isEmpty) const Text('No yields recorded', style: TextStyle(color: Colors.grey))
                            else ...f.yields.map((y) => ListTile(
                                  dense: true,
                                  title: Text('${y.quantity.toStringAsFixed(3)} t'),
                                  subtitle: Text('${y.date.toLocal()}'.split(' ')[0] + (y.notes.isNotEmpty ? ' • ${y.notes}' : '')),
                                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteYield(f, y)),
                                )),
                              // Yield chart
                              if (f.yields.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 180,
                                  child: _buildYieldChart(f),
                                ),
                              ],
                            const Divider(),
                            // Quick summary
                            Text('Total yield: ${f.yields.fold<double>(0, (p, e) => p + e.quantity).toStringAsFixed(3)} t'),
                            const SizedBox(height: 4),
                            Text('Yield per ha: ${f.yields.isNotEmpty ? (f.yields.fold<double>(0, (p, e) => p + e.quantity) / f.areaHa).toStringAsFixed(3) : 'N/A'} t/ha'),
                          ],
                        ),
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

  Widget _buildYieldChart(FieldPlot f) {
    // prepare points sorted by date ascending
    final yields = List<YieldRecord>.from(f.yields)..sort((a, b) => a.date.compareTo(b.date));
    if (yields.length < 2) {
      // Small placeholder when only one point
      return Center(child: Text('Not enough data for chart', style: Theme.of(context).textTheme.bodySmall));
    }

    final firstDate = yields.first.date;
    final spots = yields.map((y) {
      final x = y.date.difference(firstDate).inDays.toDouble();
      final yv = y.quantity;
      return FlSpot(x, yv);
    }).toList();

    final maxY = yields.map((e) => e.quantity).fold<double>(0.0, (p, e) => e > p ? e : p);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(2)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: (spots.last.x - spots.first.x) / 4, getTitlesWidget: (val, meta) {
              final idx = val.toInt();
              final date = firstDate.add(Duration(days: idx));
              return Text(DateFormat.Md().format(date), style: const TextStyle(fontSize: 10));
            })),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          minX: spots.first.x,
          maxX: spots.last.x,
          minY: 0,
          maxY: (maxY * 1.2),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.green.withAlpha((0.15 * 255).toInt())),
              color: Colors.green,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

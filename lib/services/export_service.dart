import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ExportService {
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _currencyFormat = NumberFormat.currency(symbol: '\$');

  /// Export transactions to CSV file
  static Future<void> exportToCSV(
    List<Transaction> transactions, {
    String filename = 'transactions',
  }) async {
    try {
      // Create CSV data
      List<List<dynamic>> csvData = [
        // Header row
        [
          'Date',
          'Title',
          'Type',
          'Category',
          'Amount',
          'Payment Method',
          'Description',
        ],
        // Data rows
        ...transactions.map((t) => [
              _dateFormat.format(t.date),
              t.title,
              t.type.toString().split('.').last,
              t.category.toString().split('.').last,
              t.amount,
              t.paymentMethod.toString().split('.').last,
              t.description ?? '',
            ]),
      ];

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Get directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename.csv';

      // Write file
      final file = File(path);
      await file.writeAsString(csv);

      // Share the file
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Transaction Export',
        text: 'Exported ${transactions.length} transactions',
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Export transactions to PDF file
  static Future<void> exportToPDF(
    List<Transaction> transactions, {
    String filename = 'transactions_report',
    String title = 'Transaction Report',
    FinancialSummary? summary,
  }) async {
    try {
      final pdf = pw.Document();

      // Calculate summary if not provided
      final totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final netProfit = totalIncome - totalExpenses;

      // Group transactions by category
      final categoryTotals = <TransactionCategory, double>{};
      for (var transaction in transactions) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Title
              pw.Header(
                level: 0,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Date range
              pw.Text(
                'Report generated: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              if (transactions.isNotEmpty) ...[
                pw.Text(
                  'Period: ${_dateFormat.format(transactions.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b))} to ${_dateFormat.format(transactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b))}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
              pw.SizedBox(height: 30),

              // Summary section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Financial Summary',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Income:'),
                        pw.Text(
                          _currencyFormat.format(totalIncome),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Expenses:'),
                        pw.Text(
                          _currencyFormat.format(totalExpenses),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Net Profit:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          _currencyFormat.format(netProfit),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: netProfit >= 0
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Category breakdown
              pw.Text(
                'Category Breakdown',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: ['Category', 'Amount', 'Percentage'],
                data: categoryTotals.entries.map((entry) {
                  final percentage = totalExpenses + totalIncome > 0
                      ? (entry.value / (totalExpenses + totalIncome)) * 100
                      : 0;
                  return [
                    entry.key.toString().split('.').last.toUpperCase(),
                    _currencyFormat.format(entry.value),
                    '${percentage.toStringAsFixed(1)}%',
                  ];
                }).toList(),
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 30),

              // Transaction list
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Title', 'Type', 'Category', 'Amount'],
                data: transactions.map((t) => [
                      _dateFormat.format(t.date),
                      t.title,
                      t.type.toString().split('.').last.toUpperCase(),
                      t.category.toString().split('.').last.toUpperCase(),
                      _currencyFormat.format(t.amount),
                    ]).toList(),
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerRight,
                },
              ),
            ];
          },
        ),
      );

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Transaction Report',
        text: 'Financial report with ${transactions.length} transactions',
      );
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Show export options dialog
  static Future<void> showExportDialog(
    BuildContext context,
    List<Transaction> transactions,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export ${transactions.length} transactions',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: const Text('Excel-compatible spreadsheet'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await exportToCSV(transactions);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('CSV exported successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to export: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: const Text('Formatted report with summary'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await exportToPDF(transactions);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF exported successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to export: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class ExportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<File> exportToCSV(List<Task> tasks) async {
    final List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'Title',
      'Description',
      'Due Date',
      'Due Time',
      'Status',
      'Completed At',
      'Repeat Type',
      'Repeat Days',
      'Created At',
    ]);

    // Data rows
    for (final task in tasks) {
      rows.add([
        task.title,
        task.description,
        DateFormat('yyyy-MM-dd').format(task.dueDate),
        task.dueTime != null ? DateFormat('HH:mm').format(task.dueTime!) : '',
        task.isCompleted ? 'Completed' : 'Pending',
        task.completedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(task.completedAt!) : '',
        task.repeatType,
        task.repeatDays ?? '',
        DateFormat('yyyy-MM-dd HH:mm').format(task.createdAt),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
    await file.writeAsString(csv);
    return file;
  }

  Future<File> exportToPDF(List<Task> tasks) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Task Management Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${dateTimeFormat.format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Tasks: ${tasks.length}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Completed: ${tasks.where((t) => t.isCompleted).length}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Pending: ${tasks.where((t) => !t.isCompleted).length}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 30),
            ...tasks.map((task) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            task.title,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: task.isCompleted ? PdfColors.green : PdfColors.orange,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                          ),
                          child: pw.Text(
                            task.isCompleted ? 'Completed' : 'Pending',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      task.description,
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Due Date: ${dateFormat.format(task.dueDate)}',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                    if (task.dueTime != null)
                      pw.Text(
                        'Due Time: ${timeFormat.format(task.dueTime!)}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                    if (task.repeatType != 'none')
                      pw.Text(
                        'Repeat: ${task.repeatType}${task.repeatDays != null ? ' (${task.repeatDays})' : ''}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                    if (task.completedAt != null)
                      pw.Text(
                        'Completed At: ${dateTimeFormat.format(task.completedAt!)}',
                        style: pw.TextStyle(fontSize: 11, color: PdfColors.green),
                      ),
                  ],
                ),
              )),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> exportViaEmail(List<Task> tasks, {String format = 'csv'}) async {
    File file;
    if (format == 'pdf') {
      file = await exportToPDF(tasks);
    } else {
      file = await exportToCSV(tasks);
    }

    // Share the file (opens email app or share dialog)
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Task Management Export',
      text: 'Please find attached the task management export.',
    );
  }

  Future<void> exportAllTasks({String format = 'csv'}) async {
    final tasks = await _dbHelper.getAllTasks();
    if (format == 'pdf') {
      final file = await exportToPDF(tasks);
      await Share.shareXFiles([XFile(file.path)]);
    } else {
      final file = await exportToCSV(tasks);
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  Future<void> exportTodayTasks({String format = 'csv'}) async {
    final tasks = await _dbHelper.getTodayTasks();
    if (format == 'pdf') {
      final file = await exportToPDF(tasks);
      await Share.shareXFiles([XFile(file.path)]);
    } else {
      final file = await exportToCSV(tasks);
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  Future<void> exportCompletedTasks({String format = 'csv'}) async {
    final tasks = await _dbHelper.getCompletedTasks();
    if (format == 'pdf') {
      final file = await exportToPDF(tasks);
      await Share.shareXFiles([XFile(file.path)]);
    } else {
      final file = await exportToCSV(tasks);
      await Share.shareXFiles([XFile(file.path)]);
    }
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/export_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final exportService = ExportService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(
              themeProvider.themeMode == ThemeMode.system
                  ? 'System Default'
                  : themeProvider.themeMode == ThemeMode.light
                      ? 'Light'
                      : 'Dark',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Light'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setThemeMode(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Dark'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setThemeMode(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('System Default'),
                        leading: Radio<ThemeMode>(
                          value: ThemeMode.system,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setThemeMode(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Notification Sound'),
            subtitle: Text(themeProvider.notificationSound),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Notification Sound'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Default'),
                        leading: Radio<String>(
                          value: 'default',
                          groupValue: themeProvider.notificationSound,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setNotificationSound(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Gentle'),
                        leading: Radio<String>(
                          value: 'gentle',
                          groupValue: themeProvider.notificationSound,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setNotificationSound(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Alert'),
                        leading: Radio<String>(
                          value: 'alert',
                          groupValue: themeProvider.notificationSound,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setNotificationSound(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Export',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Export All Tasks'),
            subtitle: const Text('Export all tasks to CSV or PDF'),
            leading: const Icon(Icons.upload_file),
            onTap: () async {
              final format = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Export Format'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('CSV'),
                        leading: const Icon(Icons.table_chart),
                        onTap: () => Navigator.pop(context, 'csv'),
                      ),
                      ListTile(
                        title: const Text('PDF'),
                        leading: const Icon(Icons.picture_as_pdf),
                        onTap: () => Navigator.pop(context, 'pdf'),
                      ),
                    ],
                  ),
                ),
              );

              if (format != null) {
                try {
                  await exportService.exportAllTasks(format: format);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tasks exported as $format')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error exporting: $e')),
                    );
                  }
                }
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('Task Management App'),
            subtitle: Text('Manage your daily tasks effectively'),
          ),
        ],
      ),
    );
  }
}


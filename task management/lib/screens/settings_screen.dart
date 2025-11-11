// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import '../providers/theme_provider.dart';
// import '../services/export_service.dart';
// import '../widgets/custom_background_container.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//
//   Future<void> _pickImage(BuildContext context) async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//     if (image != null) {
//       if (context.mounted) {
//         Provider.of<ThemeProvider>(context, listen: false)
//             .setBackgroundImage(image.path);
//       }
//     }
//   }
//
//   void _showColorPicker(BuildContext context) {
//     Color pickerColor = Colors.blue;
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Pick a background color'),
//           content: SingleChildScrollView(
//             child: ColorPicker(
//               pickerColor: pickerColor,
//               onColorChanged: (Color color) {
//                 pickerColor = color;
//               },
//               labelTypes: const [
//                 ColorLabelType.hsl,
//                 ColorLabelType.rgb,
//                 ColorLabelType.hex,
//               ],
//               pickerAreaHeightPercent: 0.8,
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Select'),
//               onPressed: () {
//                 Provider.of<ThemeProvider>(context, listen: false)
//                     .setBackgroundColor(pickerColor);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final exportService = ExportService();
//
//     return CustomBackgroundContainer(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           title: const Text('Settings'),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: ListView(
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Appearance',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: const Text('Theme Mode'),
//               subtitle: Text(
//                 themeProvider.themeMode == ThemeMode.system
//                     ? 'System Default'
//                     : themeProvider.themeMode == ThemeMode.light
//                     ? 'Light'
//                     : 'Dark',
//               ),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Select Theme'),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         RadioListTile<ThemeMode>(
//                           title: const Text('Light'),
//                           value: ThemeMode.light,
//                           groupValue: themeProvider.themeMode,
//                           onChanged: (value) {
//                             if (value != null) {
//                               themeProvider.setThemeMode(value);
//                               Navigator.pop(context);
//                             }
//                           },
//                         ),
//                         RadioListTile<ThemeMode>(
//                           title: const Text('Dark'),
//                           value: ThemeMode.dark,
//                           groupValue: themeProvider.themeMode,
//                           onChanged: (value) {
//                             if (value != null) {
//                               themeProvider.setThemeMode(value);
//                               Navigator.pop(context);
//                             }
//                           },
//                         ),
//                         RadioListTile<ThemeMode>(
//                           title: const Text('System Default'),
//                           value: ThemeMode.system,
//                           groupValue: themeProvider.themeMode,
//                           onChanged: (value) {
//                             if (value != null) {
//                               themeProvider.setThemeMode(value);
//                               Navigator.pop(context);
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const Divider(),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Background',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: const Text('Custom Image Background'),
//               subtitle: Text(
//                 themeProvider.backgroundSettings.imagePath != null
//                     ? 'Custom image selected'
//                     : 'No custom image',
//               ),
//               trailing: IconButton(
//                 icon: const Icon(Icons.image),
//                 onPressed: () => _pickImage(context),
//               ),
//             ),
//             ListTile(
//               title: const Text('Custom Color Background'),
//               subtitle: Text(
//                 themeProvider.backgroundSettings.backgroundColor != null
//                     ? 'Custom color selected'
//                     : 'No custom color',
//               ),
//               trailing: IconButton(
//                 icon: const Icon(Icons.color_lens),
//                 onPressed: () => _showColorPicker(context),
//               ),
//             ),
//             ListTile(
//               title: const Text('Reset to Default Background'),
//               subtitle: const Text('Restore default background'),
//               trailing: IconButton(
//                 icon: const Icon(Icons.restore),
//                 onPressed: () => themeProvider.resetBackgroundToDefault(),
//               ),
//             ),
//             const Divider(),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Notifications',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: const Text('Notification Sound'),
//               subtitle: Text(themeProvider.notificationSound),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Select Notification Sound'),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         RadioListTile<String>(
//                           title: const Text('Default'),
//                           value: 'default',
//                           groupValue: themeProvider.notificationSound,
//                           onChanged: (value) {
//                             if (value != null) {
//                               themeProvider.setNotificationSound(value);
//                               Navigator.pop(context);
//                             }
//                           },
//                         ),
//                         RadioListTile<String>(
//                           title: const Text('Gentle'),
//                           value: 'gentle',
//                           groupValue: themeProvider.notificationSound,
//                           onChanged: (value) {
//                             if (value != null) {
//                               themeProvider.setNotificationSound(value);
//                               Navigator.pop(context);
//                             }
//                           },
//                         ),
//                         RadioListTile<String>(
//                           title: const Text('Alert'),
//                           value: 'alert',
//                           groupValue: themeProvider.notificationSound,
//                           onChanged: (value) {
//                             if (value != null) {
//                               themeProvider.setNotificationSound(value);
//                               Navigator.pop(context);
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const Divider(),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Export',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: const Text('Export All Tasks'),
//               subtitle: const Text('Export all tasks to CSV or PDF'),
//               leading: const Icon(Icons.upload_file),
//               onTap: () async {
//                 final format = await showDialog<String>(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Export Format'),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ListTile(
//                           title: const Text('CSV'),
//                           leading: const Icon(Icons.table_chart),
//                           onTap: () => Navigator.pop(context, 'csv'),
//                         ),
//                         ListTile(
//                           title: const Text('PDF'),
//                           leading: const Icon(Icons.picture_as_pdf),
//                           onTap: () => Navigator.pop(context, 'pdf'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//
//                 if (format != null) {
//                   try {
//                     await exportService.exportAllTasks(format: format);
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Tasks exported as $format')),
//                       );
//                     }
//                   } catch (e) {
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error exporting: $e')),
//                       );
//                     }
//                   }
//                 }
//               },
//             ),
//             const Divider(),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'About',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const ListTile(
//               title: Text('Version'),
//               subtitle: Text('1.0.0'),
//             ),
//             const ListTile(
//               title: Text('Task Management App'),
//               subtitle: Text('Manage your daily tasks effectively'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import '../services/export_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (context.mounted) {
        Provider.of<ThemeProvider>(context, listen: false)
            .setBackgroundImage(image.path);
      }
    }
  }

  void _showColorPicker(BuildContext context) {
    Color pickerColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a background color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              labelTypes: const [
                ColorLabelType.hsl,
                ColorLabelType.rgb,
                ColorLabelType.hex,
              ],
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .setBackgroundColor(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                      RadioListTile<ThemeMode>(
                        title: const Text('Light'),
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Dark'),
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('System Default'),
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
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
              'Background',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Custom Image Background'),
            subtitle: Text(
              themeProvider.backgroundSettings.imagePath != null
                  ? 'Custom image selected'
                  : 'No custom image',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.image),
              onPressed: () => _pickImage(context),
            ),
          ),
          ListTile(
            title: const Text('Custom Color Background'),
            subtitle: Text(
              themeProvider.backgroundSettings.backgroundColor != null
                  ? 'Custom color selected'
                  : 'No custom color',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: () => _showColorPicker(context),
            ),
          ),
          ListTile(
            title: const Text('Reset to Default Background'),
            subtitle: const Text('Restore default background'),
            trailing: IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () => themeProvider.resetBackgroundToDefault(),
            ),
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
                      RadioListTile<String>(
                        title: const Text('Default'),
                        value: 'default',
                        groupValue: themeProvider.notificationSound,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setNotificationSound(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Gentle'),
                        value: 'gentle',
                        groupValue: themeProvider.notificationSound,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setNotificationSound(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Alert'),
                        value: 'alert',
                        groupValue: themeProvider.notificationSound,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setNotificationSound(value);
                            Navigator.pop(context);
                          }
                        },
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
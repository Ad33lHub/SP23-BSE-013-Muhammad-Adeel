import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'google_drive_service.dart';

class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleDriveService _driveService = GoogleDriveService();

  // Create backup (export to JSON and optionally upload to Drive)
  Future<Map<String, dynamic>> createBackup({bool uploadToDrive = false}) async {
    try {
      final backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'products': await _exportCollection('products'),
        'sales': await _exportCollection('sales'),
        'customers': await _exportCollection('customers'),
        'ledgerEntries': await _exportCollection('ledgerEntries'),
      };

      // Save to local file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonEncode(backup));

      String? driveFileId;
      if (uploadToDrive) {
        final isSignedIn = _driveService.isSignedIn || await _driveService.signIn();
        if (isSignedIn) {
          driveFileId = await _driveService.uploadFile(file);
        }
      }

      return {
        'success': true,
        'filePath': file.path,
        'timestamp': timestamp,
        'driveFileId': driveFileId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Export a Firestore collection
  Future<List<Map<String, dynamic>>> _exportCollection(String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error exporting $collectionName: $e');
      return [];
    }
  }

  // Restore from local file
  Future<Map<String, dynamic>> restoreBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'success': false, 'error': 'Backup file not found'};
      }

      final contents = await file.readAsString();
      final backup = jsonDecode(contents) as Map<String, dynamic>;

      await _performRestore(backup);

      return {
        'success': true,
        'message': 'Backup restored successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Restore from Google Drive
  Future<Map<String, dynamic>> restoreFromDrive(String fileId) async {
    try {
      final isSignedIn = _driveService.isSignedIn || await _driveService.signIn();
      if (!isSignedIn) {
        return {'success': false, 'error': 'Not signed in to Google Drive'};
      }

      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/restore_${DateTime.now().millisecondsSinceEpoch}.json';
      
      final file = await _driveService.downloadFile(fileId, savePath);
      if (file == null) {
        return {'success': false, 'error': 'Failed to download file'};
      }

      final contents = await file.readAsString();
      final backup = jsonDecode(contents) as Map<String, dynamic>;

      await _performRestore(backup);

      return {
        'success': true,
        'message': 'Backup restored from Drive successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Helper to perform the data import
  Future<void> _performRestore(Map<String, dynamic> backup) async {
    await _importCollection('products', backup['products'] as List<dynamic>);
    await _importCollection('sales', backup['sales'] as List<dynamic>);
    await _importCollection('customers', backup['customers'] as List<dynamic>);
    await _importCollection('ledgerEntries', backup['ledgerEntries'] as List<dynamic>);
  }

  // Import collection from backup
  Future<void> _importCollection(String collectionName, List<dynamic> items) async {
    try {
      final batch = _firestore.batch();
      int count = 0;

      for (final item in items) {
        final data = Map<String, dynamic>.from(item as Map);
        final docId = data.remove('id') as String?;

        if (docId != null) {
          final docRef = _firestore.collection(collectionName).doc(docId);
          batch.set(docRef, data, SetOptions(merge: true));
          count++;

          // Commit in batches of 500
          if (count % 500 == 0) {
            await batch.commit();
          }
        }
      }

      // Commit remaining
      if (count % 500 != 0) {
        await batch.commit();
      }
    } catch (e) {
      print('Error importing $collectionName: $e');
    }
  }

  // List local backups
  Future<List<Map<String, dynamic>>> listLocalBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final entities = directory.listSync();
      
      final backups = <Map<String, dynamic>>[];
      
      for (final entity in entities) {
        if (entity is File && entity.path.contains('backup_') && entity.path.endsWith('.json')) {
          final stat = await entity.stat();
          final fileName = entity.path.split('/').last;
          final timestampStr = fileName.replaceAll('backup_', '').replaceAll('.json', '');
          final timestamp = int.tryParse(timestampStr) ?? 0;
          
          backups.add({
            'type': 'local',
            'filePath': entity.path,
            'fileName': fileName,
            'size': stat.size,
            'created': DateTime.fromMillisecondsSinceEpoch(timestamp),
          });
        }
      }
      return backups;
    } catch (e) {
      print('Error listing local backups: $e');
      return [];
    }
  }

  // List Drive backups
  Future<List<Map<String, dynamic>>> listDriveBackups() async {
    try {
      final isSignedIn = _driveService.isSignedIn || await _driveService.signIn();
      if (!isSignedIn) return [];

      final files = await _driveService.listBackups();
      return files.map((f) => {
        'type': 'drive',
        'id': f.id,
        'fileName': f.name,
        'size': int.tryParse(f.size ?? '0') ?? 0,
        'created': f.createdTime ?? DateTime.now(),
      }).toList();
    } catch (e) {
      print('Error listing drive backups: $e');
      return [];
    }
  }

  // Delete local backup
  Future<bool> deleteLocalBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Access to drive service forsignin check
  GoogleDriveService get driveService => _driveService;
}

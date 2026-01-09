import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/sync_provider.dart';
import '../backup/backup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Connection Status
                      _buildSectionHeader('Connection'),
                      const SizedBox(height: 12),
                      Consumer<ConnectivityProvider>(
                        builder: (context, connectivity, _) {
                          return _buildStatusCard(
                            connectivity.isOnline ? 'Online' : 'Offline',
                            connectivity.isOnline
                                ? 'Connected to internet'
                                : 'No internet connection',
                            connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                            connectivity.isOnline ? Colors.green : Colors.orange,
                            subtitle2: connectivity.lastOnlineTime != null
                                ? 'Last online: ${DateFormat('MMM dd, hh:mm a').format(connectivity.lastOnlineTime!)}'
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sync Status
                      _buildSectionHeader('Sync Status'),
                      const SizedBox(height: 12),
                      Consumer<SyncProvider>(
                        builder: (context, sync, _) {
                          return _buildStatusCard(
                            sync.isSyncing ? 'Syncing' : 'Ready',
                            sync.syncMessage ?? (sync.lastSyncTime != null
                                ? 'Last synced: ${DateFormat('MMM dd, hh:mm a').format(sync.lastSyncTime!)}'
                                : 'Not synced yet'),
                            sync.isSyncing ? Icons.sync : Icons.check_circle,
                            sync.isSyncing ? Colors.blue : Colors.green,
                            subtitle2: sync.pendingCount > 0
                                ? '${sync.pendingCount} items pending'
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // App Info
                      _buildSectionHeader('App Information'),
                      const SizedBox(height: 12),
                      _buildInfoCard('Version', '1.0.0', Icons.info),
                      const SizedBox(height: 12),
                      _buildInfoCard('Build', '1', Icons.build),
                      const SizedBox(height: 12),
                      _buildInfoCard('Database', 'SQLite + Firestore', Icons.storage),
                      const SizedBox(height: 24),

                      // Actions
                      _buildSectionHeader('Actions'),
                      const SizedBox(height: 12),
                      Consumer<SyncProvider>(
                        builder: (context, sync, _) {
                          return _buildActionButton(
                            sync.isSyncing ? 'Syncing...' : 'Sync Now',
                            Icons.sync,
                            Colors.blue,
                            sync.isSyncing ? () {} : () => sync.syncNow(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Backup & Restore',
                        Icons.backup,
                        Colors.purple,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BackupScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Clear Cache',
                        Icons.delete_sweep,
                        Colors.orange,
                        () {
                          _showConfirmDialog(
                            context,
                            'Clear Cache',
                            'This will clear all locally cached data. Are you sure?',
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cache cleared')),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatusCard(String title, String subtitle, IconData icon, Color color, {String? subtitle2}) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: subtitle2 != null ? 100 : 80,
      borderRadius: 16,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.5),
          color.withOpacity(0.2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  if (subtitle2 != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle2,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 12,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.2)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 12,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.5), color.withOpacity(0.2)],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

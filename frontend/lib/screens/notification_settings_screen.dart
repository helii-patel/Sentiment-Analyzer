import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _loading = false;

  Future<void> _requestPermission() async {
    setState(() => _loading = true);
    try {
      final granted = await NotificationService.requestPermission();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Notification permission granted.'
                : 'Permission denied. Enable it from system settings.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() => _loading = true);
    try {
      await NotificationService.showTestNotification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Request Permission'),
              subtitle: const Text('Allow alerts from SentimentPro on this device.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              enabled: !_loading,
              onTap: _requestPermission,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Send Test Notification'),
              subtitle: const Text('Send a sample notification right now.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              enabled: !_loading,
              onTap: _sendTestNotification,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/components.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DbHelper _dbHelper = DbHelper();
  final SessionManager _session = SessionManager();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    if (_session.isLoggedIn && _session.currentUserEmail != null) {
      try {
        final notifs = await _dbHelper.getUserNotifications(_session.currentUserEmail!);
        if (mounted) {
          setState(() {
            _notifications = notifs;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading notifications: $e');
        if (mounted) {
          setState(() {
            _notifications = [];
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_notifications.isEmpty) return;
    
    try {
      for (var n in _notifications) {
        if (n['isRead'] != 1) {
          await _dbHelper.markNotificationAsRead(n['id']);
        }
      }
      _loadNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua notifikasi ditandai sudah dibaca")),
        );
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null) return 'Baru saja';
    
    try {
      final date = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} hari lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _dbHelper.markNotificationAsRead(id);
      _loadNotifications();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _deleteNotification(int id, int index) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
      if (mounted) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notifikasi dihapus")),
        );
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Notifikasi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Login untuk melihat notifikasi",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                BigButton(
                  text: "Login Sekarang",
                  backgroundColor: orangeTraya,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          if (_notifications.isNotEmpty && _notifications.any((n) => n['isRead'] != 1))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                "Tandai Semua",
                style: TextStyle(color: orangeTraya),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final isRead = (n['isRead'] == 1);
                      
                      return Dismissible(
                        key: Key(n['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          await _deleteNotification(n['id'], index);
                        },
                        child: InkWell(
                          onTap: () => _markAsRead(n['id']),
                          child: Container(
                            color: isRead ? Colors.transparent : const Color(0xFFFFF0EA).withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: _getNotificationColor(n['type']),
                                  child: Icon(
                                    _getNotificationIcon(n['type']),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatDate(n['createdAt']),
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n['message'] ?? '',
                                        style: TextStyle(
                                          color: isRead ? Colors.grey.shade600 : Colors.black87,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            "Belum ada notifikasi",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Notifikasi akan muncul di sini",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'favorite':
        return Colors.red;
      case 'cart':
        return orangeTraya;
      case 'order':
        return Colors.purple;
      default:
        return brownTraya;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'favorite':
        return Icons.favorite;
      case 'cart':
        return Icons.shopping_cart;
      case 'order':
        return Icons.shopping_bag;
      default:
        return Icons.notifications_active;
    }
  }
}
// chat_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:APK_TRAYA/database/db_helper.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  Future<Database> get _db async => DbHelper().database;

  // Send message
  Future<int> sendMessage({
    required String fromEmail,
    required String toEmail,
    required String message,
    String productId = '',
  }) async {
    final db = await _db;
    return await db.insert('chat_messages', {
      'fromEmail': fromEmail,
      'toEmail': toEmail,
      'message': message,
      'productId': productId,
      'isRead': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Get messages between two users
  Future<List<Map<String, dynamic>>> getMessages(
    String user1Email,
    String user2Email,
  ) async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT * FROM chat_messages 
      WHERE (fromEmail = ? AND toEmail = ?) 
         OR (fromEmail = ? AND toEmail = ?)
      ORDER BY createdAt ASC
    ''', [user1Email, user2Email, user2Email, user1Email]);
  }

  // Get all conversations for a user
  Future<List<Map<String, dynamic>>> getConversations(String userEmail) async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT 
        CASE 
          WHEN fromEmail = ? THEN toEmail
          ELSE fromEmail
        END as chatWith,
        MAX(createdAt) as lastMessageTime,
        (SELECT message FROM chat_messages 
         WHERE (fromEmail = ? AND toEmail = chatWith) 
            OR (fromEmail = chatWith AND toEmail = ?)
         ORDER BY createdAt DESC LIMIT 1) as lastMessage,
        (SELECT COUNT(*) FROM chat_messages 
         WHERE toEmail = ? AND isRead = 0 AND fromEmail = chatWith) as unreadCount
      FROM chat_messages 
      WHERE fromEmail = ? OR toEmail = ?
      GROUP BY chatWith
      ORDER BY lastMessageTime DESC
    ''', [userEmail, userEmail, userEmail, userEmail, userEmail, userEmail]);
  }

  // Mark messages as read
  Future<int> markAsRead(String fromEmail, String toEmail) async {
    final db = await _db;
    return await db.update(
      'chat_messages',
      {'isRead': 1},
      where: 'fromEmail = ? AND toEmail = ? AND isRead = 0',
      whereArgs: [fromEmail, toEmail],
    );
  }

  // Get unread count for a user
  Future<int> getUnreadCount(String userEmail) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM chat_messages WHERE toEmail = ? AND isRead = 0',
      [userEmail],
    );
    return result.first['count'] as int;
  }
}
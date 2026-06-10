import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/views/notification_screen.dart';
import 'package:APK_TRAYA/components.dart';

// ======================== CHAT SERVICE ========================
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  Future<Database> get _db async {
    final dbHelper = DbHelper();
    return await dbHelper.database;
  }

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

  Future<List<Map<String, dynamic>>> getMessages(
    String user1Email,
    String user2Email,
  ) async {
    final db = await _db;
    return await db.rawQuery(
      '''
      SELECT * FROM chat_messages 
      WHERE (fromEmail = ? AND toEmail = ?) 
         OR (fromEmail = ? AND toEmail = ?)
      ORDER BY createdAt ASC
    ''',
      [user1Email, user2Email, user2Email, user1Email],
    );
  }

  Future<List<Map<String, dynamic>>> getConversations(String userEmail) async {
    final db = await _db;
    return await db.rawQuery(
      '''
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
    ''',
      [userEmail, userEmail, userEmail, userEmail, userEmail, userEmail],
    );
  }

  Future<int> markAsRead(String fromEmail, String toEmail) async {
    final db = await _db;
    return await db.update(
      'chat_messages',
      {'isRead': 1},
      where: 'fromEmail = ? AND toEmail = ? AND isRead = 0',
      whereArgs: [fromEmail, toEmail],
    );
  }

  Future<int> getUnreadCount(String userEmail) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM chat_messages WHERE toEmail = ? AND isRead = 0',
      [userEmail],
    );
    return result.first['count'] as int;
  }
}

// ======================== INBOX SCREEN (DAFTAR SEMUA CHAT) ========================
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late final SessionManager _session;
  late final ChatService _chatService;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  int _unreadTotal = 0;

  @override
  void initState() {
    super.initState();
    _session = SessionManager();
    _chatService = ChatService();
    _session.addListener(_loadConversations);
    _loadConversations();
  }

  @override
  void dispose() {
    _session.removeListener(_loadConversations);
    super.dispose();
  }

  Future<void> _loadConversations() async {
    if (!_session.isLoggedIn) {
      setState(() {
        _conversations = [];
        _isLoading = false;
        _unreadTotal = 0;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final convs = await _chatService.getConversations(
        _session.currentUserEmail!,
      );
      final unreadTotal = await _chatService.getUnreadCount(
        _session.currentUserEmail!,
      );

      if (mounted) {
        setState(() {
          _conversations = convs;
          _unreadTotal = unreadTotal;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final date = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 0) return '${diff.inDays} h';
      if (diff.inHours > 0) return '${diff.inHours} j';
      if (diff.inMinutes > 0) return '${diff.inMinutes} m';
      return 'Baru saja';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.isLoggedIn) {
      return _buildNotLoggedInUI();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              "Pesan",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            if (_unreadTotal > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _unreadTotal.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final chat = _conversations[index];
                final partnerEmail = chat['chatWith'].toString();
                final partnerName = partnerEmail.split('@').first;
                final lastMessage = chat['lastMessage'] ?? 'Mulai percakapan';
                final lastTime = _formatTime(chat['lastMessageTime']);
                final unreadCount = chat['unreadCount'] ?? 0;

                return _buildChatCard(
                  email: partnerEmail,
                  name: partnerName,
                  lastMessage: lastMessage,
                  time: lastTime,
                  unreadCount: unreadCount,
                );
              },
            ),
    );
  }

  Widget _buildChatCard({
    required String email,
    required String name,
    required String lastMessage,
    required String time,
    required int unreadCount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFFFF0EA),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: brownTraya,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unreadCount > 0 ? Colors.black : Colors.black54,
            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        trailing: unreadCount > 0
            ? Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : null,
        onTap: () async {
          await _chatService.markAsRead(email, _session.currentUserEmail!);
          _loadConversations();
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatRoomScreen(partnerEmail: email, partnerName: name),
              ),
            ).then((_) => _loadConversations());
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Belum ada pesan",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulai chat dengan penjual produk",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInUI() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pesan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                "Login untuk Chat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan login terlebih dahulu untuk mengirim pesan",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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
}

// ======================== CHAT ROOM SCREEN (CHAT DENGAN 1 ORANG) ========================
class ChatRoomScreen extends StatefulWidget {
  final String partnerEmail;
  final String partnerName;
  final String? productId;
  final String? productTitle;

  const ChatRoomScreen({
    super.key,
    required this.partnerEmail,
    required this.partnerName,
    this.productId,
    this.productTitle,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _msgCtr = TextEditingController();
  late final SessionManager _session;
  late final ChatService _chatService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _session = SessionManager();
    _chatService = ChatService();
    _loadMessages();
  }

  @override
  void dispose() {
    _msgCtr.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (!_session.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _chatService.markAsRead(
        widget.partnerEmail,
        _session.currentUserEmail!,
      );
      final msgs = await _chatService.getMessages(
        _session.currentUserEmail!,
        widget.partnerEmail,
      );
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(msgs);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (!_session.isLoggedIn) return;

    try {
      await _chatService.sendMessage(
        fromEmail: _session.currentUserEmail!,
        toEmail: widget.partnerEmail,
        message: text,
        productId: widget.productId ?? '',
      );
      _msgCtr.clear();
      _loadMessages();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal mengirim pesan")));
      }
    }
  }

  void _sendNegotiation(String price) async {
    if (!_session.isLoggedIn) return;

    final message =
        "💬 SISTEM PENAWARAN: Saya mengajukan penawaran harga Rp $price untuk produk ini. Mohon konfirmasi.";
    try {
      await _chatService.sendMessage(
        fromEmail: _session.currentUserEmail!,
        toEmail: widget.partnerEmail,
        message: message,
        productId: widget.productId ?? '',
      );
      _loadMessages();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Penawaran terkirim!")));
      }
    } catch (e) {
      debugPrint('Error sending negotiation: $e');
    }
  }

  void _showNegotiationModal() {
    final TextEditingController negoCtr = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Ajukan Penawaran - ${widget.partnerName}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Masukkan harga yang Anda tawarkan",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: negoCtr,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Harga Tawaran (Rp)",
                hintText: "Contoh: 200000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.monetization_on,
                  color: orangeTraya,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeTraya,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (negoCtr.text.isNotEmpty) {
                Navigator.pop(context);
                _sendNegotiation(negoCtr.text);
              }
            },
            child: const Text(
              "Kirim Penawaran",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final date = DateTime.parse(dateTimeString);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: const BackButton(color: Colors.black),
          title: Text(
            widget.partnerName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Login untuk Chat",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan login terlebih dahulu untuk melanjutkan chat",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                BigButton(
                  text: "Login Sekarang",
                  backgroundColor: orangeTraya,
                  onTap: () {
                    Navigator.pushReplacement(
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.partnerName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (widget.productId != null)
            TextButton.icon(
              icon: const Icon(
                Icons.gavel_rounded,
                color: brownTraya,
                size: 20,
              ),
              label: const Text(
                "Nego",
                style: TextStyle(
                  color: brownTraya,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _showNegotiationModal,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (widget.productTitle != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag, color: brownTraya),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Produk: ${widget.productTitle}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Mulai chat dengan ${widget.partnerName}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[_messages.length - 1 - index];
                      final bool isMe =
                          m['fromEmail'] == _session.currentUserEmail;
                      final bool isSystem = (m['message'] as String).contains(
                        'SISTEM PENAWARAN',
                      );

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isSystem
                                ? Colors.amber.shade50
                                : (isMe
                                      ? const Color(0xFFFFF0EA)
                                      : const Color(0xFFF1F1F1)),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15),
                              topRight: const Radius.circular(15),
                              bottomLeft: Radius.circular(isMe ? 15 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 15),
                            ),
                            border: isSystem
                                ? Border.all(color: Colors.amber.shade300)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['message'],
                                style: TextStyle(
                                  color: isSystem
                                      ? Colors.orange.shade900
                                      : (isMe ? brownTraya : Colors.black87),
                                  fontWeight: isSystem
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(m['createdAt']),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _msgCtr,
                decoration: const InputDecoration(
                  hintText: "Ketik pesan...",
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _sendMessage(_msgCtr.text),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: orangeTraya,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_msgCtr.text),
            ),
          ),
        ],
      ),
    );
  }
}

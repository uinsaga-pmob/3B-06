import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/notification_screen.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/components.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();

    if (!session.isLoggedIn) {
      return _buildNotLoggedInUI(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pesan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChatItem(
            context,
            name: "TRaya Official",
            msg: "Selamat datang di TRaya! Temukan berbagai produk preloved terbaik.",
            time: "Baru saja",
            unreadCount: 1,
            avatar: "T",
          ),
          _buildChatItem(
            context,
            name: "Admin Support",
            msg: "Ada yang bisa kami bantu? Silakan hubungi kami jika ada kendala.",
            time: "Kemarin",
            unreadCount: 0,
            avatar: "A",
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pesan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 28),
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

  Widget _buildChatItem(
    BuildContext context, {
    required String name,
    required String msg,
    required String time,
    required int unreadCount,
    required String avatar,
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
            avatar,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brownTraya),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          msg,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            if (unreadCount > 0)
              CircleAvatar(
                radius: 9,
                backgroundColor: orangeTraya,
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatRoomScreen(partnerName: name)),
        ),
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  final String partnerName;
  final String? sellerEmail;
  
  const ChatRoomScreen({
    super.key,
    required this.partnerName,
    this.sellerEmail,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'partner',
      'text': 'Halo, ada yang bisa dibantu mengenai produk preloved ini?',
      'time': '10:00',
    },
  ];
  final TextEditingController _msgCtr = TextEditingController();
  final SessionManager _session = SessionManager();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'sender': 'me',
        'text': text,
        'time': _getCurrentTime(),
      });
    });
    _msgCtr.clear();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.monetization_on, color: orangeTraya),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (negoCtr.text.isNotEmpty) {
                Navigator.pop(context);
                _sendMessage(
                  "💬 SISTEM PENAWARAN: Saya mengajukan penawaran harga Rp ${negoCtr.text} untuk produk ini. Mohon konfirmasi."
                );
              }
            },
            child: const Text("Kirim Penawaran", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.gavel_rounded, color: brownTraya, size: 20),
            label: const Text(
              "Nego",
              style: TextStyle(color: brownTraya, fontWeight: FontWeight.bold),
            ),
            onPressed: _showNegotiationModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[_messages.length - 1 - index];
                final bool isMe = m['sender'] == 'me';
                final bool isSystem = m['text'].contains('[SISTEM') || m['text'].contains('SISTEM PENAWARAN');
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isSystem
                          ? Colors.amber.shade50
                          : (isMe ? const Color(0xFFFFF0EA) : const Color(0xFFF1F1F1)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isMe ? 15 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 15),
                      ),
                      border: isSystem ? Border.all(color: Colors.amber.shade300) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['text'],
                          style: TextStyle(
                            color: isSystem
                                ? Colors.orange.shade900
                                : (isMe ? brownTraya : Colors.black87),
                            fontWeight: isSystem ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m['time'] ?? '',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                onSubmitted: _sendMessage,
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
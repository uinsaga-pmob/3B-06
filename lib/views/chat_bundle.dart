import 'package:flutter/material.dart';

// --- 1. INBOX SCREEN (Daftar Pesan) ---
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Inbox',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Di sini saya tambahkan GestureDetector agar kamu bisa ngetes buka ChatDetail
      body: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDetailScreen()));
        },
        child: _buildEmptyMessageView(),
      ),
    );
  }

  Widget _buildEmptyMessageView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/inbox.png', width: 250, height: 150, fit: BoxFit.contain),
          const SizedBox(height: 20),
          const Text(
            'Belum ada message',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// --- 2. CHAT DETAIL SCREEN (Percakapan) ---
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [
    {"text": "Halo kak, barang ini ready ga?", "isMe": true},
    {"text": "Halo! Masih ready kak, size M ya.", "isMe": false},
    {"text": "Kondisinya gimana kak? Ada minus?", "isMe": true},
    {"text": "Mulus kak, like new 9/10. Bisa langsung check out ya.", "isMe": false},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add({"text": _controller.text, "isMe": true});
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: const Row(
          children: [
            CircleAvatar(radius: 16, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 20, color: Colors.white)),
            SizedBox(width: 10),
            Text("Jepstore", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildChatBubble(messages[index]['text'], messages[index]['isMe']),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: "Tulis pesan...", border: InputBorder.none),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(icon: const Icon(Icons.send, color: Colors.orange), onPressed: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFF69C73) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
      ),
    );
  }
}

// --- 3. NOTIFICATION SCREEN (Daftar Notif) ---
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        children: [
          _buildNotifItem("Pesanan Berhasil", "Pembayaran konfirmasi.", "2 menit lalu", Icons.check_circle, Colors.green),
          _buildNotifItem("Info Promo", "Diskon 50% berakhir hari ini!", "1 jam lalu", Icons.local_offer, Colors.orange),
          _buildNotifItem("Pengiriman", "Paket sedang dibawa kurir.", "Kemarin", Icons.local_shipping, Colors.blue),
          _buildNotifItem("Akun", "Profil berhasil diperbarui.", "2 hari lalu", Icons.person, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildNotifItem(String title, String body, String time, IconData icon, Color color) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(body, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
        const Divider(height: 1, indent: 70),
      ],
    );
  }
}
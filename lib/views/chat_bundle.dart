import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/notification_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Inbox", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
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
            name: "Merchant TRaya",
            msg: "Halo, produk sandang ini masih bisa nego sedikit ya.",
            time: "14:20",
            unreadCount: 1,
          ),
          _buildChatItem(
            context,
            name: "Sistem Logistik",
            msg: "Barang pesanan Anda sudah diserahkan ke kurir pengiriman.",
            time: "Kemarin",
            unreadCount: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, {required String name, required String msg, required String time, required int unreadCount}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(radius: 25, backgroundColor: Color(0xFFFFF0EA), child: Icon(Icons.person, color: Color(0xFF7F2F00))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            if (unreadCount > 0)
              CircleAvatar(radius: 9, backgroundColor: const Color(0xFFF69C73), child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(partnerName: name))),
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  final String partnerName;
  const ChatRoomScreen({super.key, required this.partnerName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'partner', 'text': 'Halo, ada yang bisa dibantu mengenai produk preloved ini?'},
  ];
  final TextEditingController _msgCtr = TextEditingController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'me', 'text': text});
    });
    _msgCtr.clear();
  }

  void _tampilkanModalNego() {
    final TextEditingController negoCtr = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Ajukan Penawaran - ${widget.partnerName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: TextField(
          controller: negoCtr,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Masukkan Harga Tawaran (Rp)", hintText: "Cth: 220000"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7F2F00)),
            onPressed: () {
              if (negoCtr.text.isNotEmpty) {
                Navigator.pop(context);
                _sendMessage("[SISTEM PENAWARAN] Mengajukan harga baru: Rp ${negoCtr.text}");
              }
            },
            child: const Text("Kirim Nego", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: Text(widget.partnerName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.gavel_rounded, color: Color(0xFF7F2F00), size: 18),
            label: const Text("Nego", style: TextStyle(color: Color(0xFF7F2F00), fontWeight: FontWeight.bold)),
            onPressed: _tampilkanModalNego,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                bool isMe = m['sender'] == 'me';
                bool isSystem = m['text'].contains('[SISTEM');

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSystem 
                          ? Colors.amber.shade50
                          : (isMe ? const Color(0xFFFFF0EA) : const Color(0xFFF1F1F1)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isMe ? 15 : 0), bottomRight: Radius.circular(isMe ? 0 : 15),
                      ),
                      border: isSystem ? Border.all(color: Colors.amber.shade300) : null,
                    ),
                    child: Text(
                      m['text'], 
                      style: TextStyle(
                        color: isSystem ? Colors.orange.shade900 : (isMe ? const Color(0xFF7F2F00) : Colors.black87),
                        fontWeight: isSystem ? FontWeight.bold : FontWeight.normal
                      )
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF6F6F6), borderRadius: BorderRadius.circular(20)),
                    child: TextField(controller: _msgCtr, decoration: const InputDecoration(hintText: "Ketik pesan...", border: InputBorder.none, isDense: true)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFF7F2F00)), onPressed: () => _sendMessage(_msgCtr.text)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
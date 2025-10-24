import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesPage extends StatefulWidget {
  final String chatId; // requerido
  final String? otherUserId; // opcional: para indicador "Escribiendo…"
  const MessagesPage({super.key, required this.chatId, this.otherUserId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;

  late final CollectionReference _msgsCol;
  late final DocumentReference _chatDoc;
  late final CollectionReference _typingCol;

  Timer? _typingDebounce;
  bool _iAmTyping = false;

  @override
  void initState() {
    super.initState();
    _chatDoc = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId);
    _msgsCol = _chatDoc.collection('mensajes');
    _typingCol = _chatDoc.collection('typing');
    _ensureChatMetadata();
  }

  Future<void> _ensureChatMetadata() async {
    if (user == null) return;
    await _chatDoc.set({
      'participants': FieldValue.arrayUnion([
        user!.uid,
        if (widget.otherUserId != null) widget.otherUserId,
      ]),
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final mensajesRef = _msgsCol.orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Mensajes"),
            const SizedBox(width: 8),
            if (widget.otherUserId != null)
              StreamBuilder<DocumentSnapshot>(
                stream: _typingCol.doc(widget.otherUserId).snapshots(),
                builder: (_, snap) {
                  final typing =
                      (snap.data?.data() as Map<String, dynamic>?)?['typing'] ==
                      true;
                  if (!typing) return const SizedBox.shrink();
                  return const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Escribiendo…",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: mensajesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Error cargando mensajes"));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aún no hay mensajes.\nComienza la conversación 👋",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final msgId = docs[index].id;
                    final isMe = data['senderId'] == user?.uid;
                    final dt = (data['timestamp'] as Timestamp?)?.toDate();
                    final text = (data['texto'] as String?) ?? '';

                    final bubble = Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: isMe ? () => _confirmDelete(msgId) : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.teal.shade300
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dt != null
                                    ? "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}"
                                    : '',
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    // Separador de fecha al cambiar de día
                    Widget dateSeparator = const SizedBox.shrink();
                    if (dt != null) {
                      final isFirst = index == 0;
                      bool showSeparator = false;
                      if (isFirst) {
                        showSeparator = true;
                      } else {
                        final prev =
                            (docs[index - 1].data() as Map<String, dynamic>);
                        final prevDt = (prev['timestamp'] as Timestamp?)
                            ?.toDate();
                        showSeparator =
                            prevDt == null ||
                            prevDt.day != dt.day ||
                            prevDt.month != dt.month ||
                            prevDt.year != dt.year;
                      }
                      if (showSeparator) {
                        dateSeparator = Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${dt.day}/${dt.month}/${dt.year}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (dateSeparator is! SizedBox) dateSeparator,
                        bubble,
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    onChanged: _onTypingChanged,
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Indicador "escribiendo" ---
  void _onTypingChanged(String value) {
    if (user == null) return;

    if (!_iAmTyping) {
      _iAmTyping = true;
      _typingCol.doc(user!.uid).set({
        'typing': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 900), () {
      _iAmTyping = false;
      _typingCol.doc(user!.uid).set({
        'typing': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> _sendMessage() async {
    final texto = _messageController.text.trim();
    if (texto.isEmpty || user == null) return;

    if (_iAmTyping) {
      _iAmTyping = false;
      unawaited(
        _typingCol.doc(user!.uid).set({
          'typing': false,
        }, SetOptions(merge: true)),
      );
    }

    final msgRef = _msgsCol.doc();
    final msgData = {
      'texto': texto,
      'senderId': user!.uid,
      'senderEmail': user!.email,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final batch = FirebaseFirestore.instance.batch();
    batch.set(msgRef, msgData);
    batch.set(_chatDoc, {
      'participants': FieldValue.arrayUnion([
        user!.uid,
        if (widget.otherUserId != null) widget.otherUserId,
      ]),
      'lastMessage': texto,
      'lastSenderId': user!.uid,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();

    _messageController.clear();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _confirmDelete(String msgId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar mensaje'),
        content: const Text('¿Quieres eliminar este mensaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _deleteMessage(msgId);
    }
  }

  Future<void> _deleteMessage(String msgId) async {
    if (user == null) return;
    final msgDoc = _msgsCol.doc(msgId);
    final snap = await msgDoc.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    if (data['senderId'] != user!.uid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes borrar tus mensajes.')),
      );
      return;
    }
    await msgDoc.delete();
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    if (_iAmTyping && user != null) {
      _typingCol.doc(user!.uid).set({'typing': false}, SetOptions(merge: true));
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

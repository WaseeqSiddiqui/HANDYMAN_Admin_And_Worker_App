import 'package:flutter/material.dart';
import '../models/service_request_model.dart';
import '../models/chat_message_model.dart';
import '../services/firestore_service.dart';
import '/utils/worker_translations.dart';

class ChatScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;
  final String workerName;

  const ChatScreen({
    super.key,
    required this.serviceRequest,
    required this.workerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.serviceRequest.customerName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.serviceRequest.serviceName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildServiceInfoBanner(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<ChatMessage>>(
                stream: _firestoreService.getChatMessagesStream(
                  widget.serviceRequest.id,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    );
                  }

                  // Auto-scroll to bottom on new message
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(messages[index]);
                    },
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildServiceInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF005DFF).withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: Color(0xFF005DFF)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${WorkerTranslations.getEnglish(WorkerTranslations.service)} ${widget.serviceRequest.serviceName} • ${widget.serviceRequest.address}',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isWorker = message.role == 'worker'; // worker is 'me' in this screen

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isWorker
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isWorker) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 20, color: Colors.grey),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isWorker
                    ? const Color(0xFF005DFF)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isWorker ? 16 : 4),
                  bottomRight: Radius.circular(isWorker ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isWorker ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isWorker ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isWorker) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF005DFF),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                decoration: InputDecoration(
                  hintText: WorkerTranslations.getEnglish(
                    WorkerTranslations.typeMessage,
                  ),
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: Color(0xFF005DFF),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF005DFF),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return WorkerTranslations.getEnglish(WorkerTranslations.justNow);
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}${WorkerTranslations.getEnglish(WorkerTranslations.mAgo)}';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}${WorkerTranslations.getEnglish(WorkerTranslations.hAgo)}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Temporary ID, better use AutoID from firestore but this works for set
      senderId: widget.serviceRequest.workerId ?? '',
      senderName: widget.workerName,
      role: 'worker',
      message: text,
      timestamp: DateTime.now(),
    );

    try {
      // Since we are setting ID manually in model, we can rely on it,
      // OR better: let Firestore generate ID.
      // The service method usage: `_servicesCollection.doc(..).collection('messages').doc(message.id).set(...)`
      // So we need a unique ID.
      // A better way is to use empty doc() to generate ID in service, but our service expects a full object.
      // Let's stick to timestamp-based or uuid for now to keep it simple without adding uuid package if not present.
      // `DateTime.now().millisecondsSinceEpoch.toString()` is risky for collision in high concurrecny but fine for chat.

      // Wait, FirestoreService.sendMessage does .doc(message.id).set().
      // I should use `_firestore.collection(...).doc().id` to generate an ID if I had access to firestore instance here.
      // Since I don't, I will use a simple unique string.

      await _firestoreService.sendMessage(widget.serviceRequest.id, message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/models/message.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/services/chat_service.dart';
import 'package:jamiifund/services/user_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final UserProfile recipient;

  const ChatDetailScreen({
    super.key,
    required this.recipient,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  String? _chatRoomId;
  String? _errorMessage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to chat';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if users are mutual followers
      final areMutual = await UserService.areMutualFollowers(currentUser.id, widget.recipient.id);
      
      if (!areMutual) {
        setState(() {
          _errorMessage = 'You can only chat with users who follow you back';
          _isLoading = false;
        });
        return;
      }
      
      // Get or create a chat room between current user and recipient
      final chatRoomId = await ChatService.getOrCreateChatRoom(
        currentUser.id,
        widget.recipient.id,
      );
      
      _chatRoomId = chatRoomId;
      
      // Load messages
      await _loadMessages();
      
      // Set up real-time subscription for new messages
      ChatService.subscribeToMessages(chatRoomId, (message) {
        if (mounted) {
          setState(() {
            _messages = [..._messages, message];
          });
          _scrollToBottom();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize chat: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_chatRoomId == null) return;
    
    try {
      final messages = await ChatService.getChatMessages(_chatRoomId!);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
      
      // Mark messages as read
      final currentUser = UserService.getCurrentUser();
      if (currentUser != null) {
        await ChatService.markDirectMessagesAsRead(_chatRoomId!, currentUser.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load messages: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatRoomId == null) return;
    
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;
    
    setState(() {
      _isSending = true;
    });

    _messageController.clear();

    try {
      await ChatService.sendDirectMessage(
        _chatRoomId!,
        currentUser.id,
        widget.recipient.id,
        text,
      );
      
      // No need to update state manually as the subscription will handle it
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF8A2BE2),
              backgroundImage: widget.recipient.avatarUrl != null
                  ? NetworkImage(widget.recipient.avatarUrl!)
                  : null,
              radius: 20,
              child: widget.recipient.avatarUrl == null
                  ? Text(
                      widget.recipient.fullName.isNotEmpty ? widget.recipient.fullName[0].toUpperCase() : '?',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipient.fullName,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.recipient.isVerified == true)
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
              _showOptionsBottomSheet();
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
        : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initializeChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A2BE2),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a conversation',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == UserService.getCurrentUser()?.id;
                          
                          // Check if we should show the date
                          final showDate = index == 0 || 
                            !_isSameDay(_messages[index].createdAt, _messages[index - 1].createdAt);
                          
                          return Column(
                            children: [
                              if (showDate)
                                _buildDateSeparator(message.createdAt),
                              
                              _buildMessageBubble(message, isMe),
                            ],
                          ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index));
                        },
                      ),
                ),
                
                // Message input
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        color: const Color(0xFF8A2BE2),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('File attachments coming soon')),
                          );
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: GoogleFonts.nunito(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: _isSending 
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Color(0xFF8A2BE2),
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                        color: const Color(0xFF8A2BE2),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final time = _formatTime(message.createdAt);
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content ?? 'Message deleted',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.blue : Colors.grey[600],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[400])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _formatDate(date),
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[400])),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF8A2BE2)),
                title: Text(
                  'View Profile',
                  style: GoogleFonts.nunito(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text(
                  'Block User',
                  style: GoogleFonts.nunito(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Block user feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: Text(
                  'Report User',
                  style: GoogleFonts.nunito(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  'Clear Chat',
                  style: GoogleFonts.nunito(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showClearChatDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Clear Chat',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to clear all messages? This cannot be undone.',
            style: GoogleFonts.nunito(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(
                  color: Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clear chat feature coming soon')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Clear',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

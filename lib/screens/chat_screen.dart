import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamiifund/models/chat_room.dart';
import 'package:jamiifund/models/message.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/services/chat_service.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _searchController = TextEditingController();
  List<ChatRoom> _chatRooms = [];
  List<ChatRoom> _filteredRooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to view chats';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final chatRooms = await ChatService.getUserChatRooms(currentUser.id);
      setState(() {
        _chatRooms = chatRooms;
        _filteredRooms = chatRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load chat rooms: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterRooms(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRooms = _chatRooms;
      });
      return;
    }

    final filteredRooms = _chatRooms.where((room) {
      return room.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    setState(() {
      _filteredRooms = filteredRooms;
    });
  }

  void _navigateToChatDetail(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chatRoom: room),
      ),
    ).then((_) {
      // Refresh rooms when returning to the list
      _loadChatRooms();
    });
  }

  void _createNewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewChatScreen(),
      ),
    ).then((_) {
      // Refresh rooms when returning to the list
      _loadChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _createNewChat,
            icon: const Icon(Icons.add_comment_outlined),
            color: const Color(0xFF8A2BE2),
            tooltip: 'New Chat',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0), // Using home index since chat is accessed from menu
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterRooms,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadChatRooms,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A2BE2),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredRooms.isEmpty
                        ? _buildEmptyState()
                        : _buildChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new chat to connect with others',
            style: GoogleFonts.nunito(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewChat,
            icon: const Icon(Icons.add),
            label: const Text('New Conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2BE2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _filteredRooms.length,
      itemBuilder: (context, index) {
        final room = _filteredRooms[index];
        return _buildChatRoomTile(room);
      },
    );
  }

  Widget _buildChatRoomTile(ChatRoom room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _navigateToChatDetail(room),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: room.isGroup ? Colors.green[100] : Colors.purple[100],
                child: Icon(
                  room.isGroup ? Icons.group : Icons.person,
                  color: room.isGroup ? Colors.green[700] : Colors.purple[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            room.name ?? 'Chat',
                            style: GoogleFonts.nunito(
                              fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (room.lastMessageTime != null)
                          Text(
                            timeago.format(room.lastMessageTime!, locale: 'en_short'),
                            style: GoogleFonts.nunito(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.lastMessage ?? 'No messages yet',
                            style: GoogleFonts.nunito(
                              color: room.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                              fontWeight: room.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (room.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8A2BE2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              room.unreadCount.toString(),
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({super.key, required this.chatRoom});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  List<XFile> _selectedMedia = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  String? _currentUserId;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentUserId = UserService.getCurrentUser()?.id;
    _loadMessages();
    
    // Mark messages as read when entering the chat
    if (_currentUserId != null) {
      ChatService.markMessagesAsRead(
        roomId: widget.chatRoom.id,
        userId: _currentUserId!,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_currentUserId == null) {
      setState(() {
        _errorMessage = 'You must be logged in to view messages';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final messages = await ChatService.getRoomMessages(widget.chatRoom.id);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      
      // Scroll to bottom after loading messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send messages')),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();
    
    final media = List<XFile>.from(_selectedMedia);
    setState(() {
      _selectedMedia = [];
      _isSending = true;
    });

    try {
      List<MediaItem>? mediaItems;
      
      // Upload media if any
      if (media.isNotEmpty) {
        mediaItems = await ChatService.uploadMessageMedia(media, _currentUserId!);
      }
      
      // Send message
      final message = await ChatService.sendMessage(
        roomId: widget.chatRoom.id,
        senderId: _currentUserId!,
        content: messageText.isNotEmpty ? messageText : null,
        media: mediaItems,
      );
      
      setState(() {
        _messages = [..._messages, message];
        _isSending = false;
      });
      
      // Scroll to bottom after sending message
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _pickMedia() async {
    try {
      final List<XFile> media = await _picker.pickMultiImage();
      if (media.isNotEmpty) {
        setState(() {
          _selectedMedia.addAll(media);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: ${e.toString()}')),
      );
    }
  }
  
  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.chatRoom.name ?? 'Chat',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (widget.chatRoom.isGroup)
            IconButton(
              onPressed: () {
                // TODO: Show group info
              },
              icon: const Icon(Icons.group),
              color: const Color(0xFF8A2BE2),
            ),
          IconButton(
            onPressed: () {
              // TODO: Show chat options
            },
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF8A2BE2),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadMessages,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A2BE2),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation!',
                                  style: GoogleFonts.nunito(
                                    color: Colors.grey[600],
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
                              final isCurrentUser = message.senderId == _currentUserId;
                              final showAvatar = !isCurrentUser;
                              
                              // Check if we need to show the date
                              bool showDate = index == 0;
                              if (index > 0) {
                                final previousMessage = _messages[index - 1];
                                final previousDate = DateTime(
                                  previousMessage.createdAt.year,
                                  previousMessage.createdAt.month,
                                  previousMessage.createdAt.day,
                                );
                                final currentDate = DateTime(
                                  message.createdAt.year,
                                  message.createdAt.month,
                                  message.createdAt.day,
                                );
                                showDate = previousDate != currentDate;
                              }
                              
                              return Column(
                                children: [
                                  if (showDate) _buildDateDivider(message.createdAt),
                                  _buildMessageBubble(message, isCurrentUser, showAvatar),
                                ],
                              );
                            },
                          ),
          ),
          if (_selectedMedia.isNotEmpty) _buildSelectedMediaPreview(),
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              DateFormat('MMM d, yyyy').format(date),
              style: GoogleFonts.nunito(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(Message message, bool isCurrentUser, bool showAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: message.senderAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        message.senderAvatar!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            message.senderName?.substring(0, 1).toUpperCase() ?? '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    )
                  : Text(
                      message.senderName?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            )
          else if (!isCurrentUser)
            const SizedBox(width: 32),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser ? const Color(0xFF8A2BE2) : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser && widget.chatRoom.isGroup)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 2.0),
                      child: Text(
                        message.senderName ?? 'Unknown',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                  if (message.hasMedia)
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: const Radius.circular(16),
                        bottom: message.content != null ? Radius.zero : const Radius.circular(16),
                      ),
                      child: Column(
                        children: message.media!.map((media) {
                          if (media.type == 'image') {
                            return Image.network(
                              media.url,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 150,
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            );
                          } else if (media.type == 'video') {
                            // TODO: Implement video player
                            return Container(
                              width: double.infinity,
                              height: 150,
                              color: Colors.black87,
                              alignment: Alignment.center,
                              child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
                            );
                          }
                          return Container();
                        }).toList(),
                      ),
                    ),
                  if (message.content != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        message.content!,
                        style: GoogleFonts.nunito(
                          color: isCurrentUser ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 4.0, left: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('h:mm a').format(message.createdAt),
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isCurrentUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0, duration: 200.ms);
  }
  
  Widget _buildSelectedMediaPreview() {
    return Container(
      height: 100,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMedia.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: kIsWeb
                    ? Image.network(
                        _selectedMedia[index].path,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_selectedMedia[index].path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _removeMedia(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: _pickMedia,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            color: const Color(0xFF8A2BE2),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.nunito(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF8A2BE2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  bool _isGroup = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  List<String> _selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to create a chat';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load mutual followers (users who follow the current user AND are followed by the current user)
      final mutualFollowers = await UserService.getMutualFollowers(currentUser.id);
      
      setState(() {
        _users = mutualFollowers;
        _filteredUsers = List.from(_users);
        _isLoading = false;
      });
      
      if (_users.isEmpty) {
        setState(() {
          _errorMessage = 'No mutual followers found. Follow some users to start chatting!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _users;
      });
      return;
    }

    final filteredUsers = _users.where((user) {
      final UserProfile profile = user;
      final fullName = profile.fullName.toLowerCase();
      final username = profile.username?.toLowerCase() ?? '';
      return fullName.contains(query.toLowerCase()) || 
             username.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = filteredUsers;
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  Future<void> _createChat() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    if (_isGroup && _groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a chat')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ChatService.createChatRoom(
        createdBy: currentUser.id,
        memberIds: [..._selectedUserIds, currentUser.id],
        name: _isGroup ? _groupNameController.text.trim() : null,
        isGroup: _isGroup,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create chat: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'New Chat',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Switch(
            value: _isGroup,
            onChanged: (value) {
              setState(() {
                _isGroup = value;
              });
            },
            activeColor: const Color(0xFF8A2BE2),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text('Group Chat'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isGroup)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterUsers,
            ),
          ),
          if (_selectedUserIds.isNotEmpty)
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _selectedUserIds.map((userId) {
                  final UserProfile user = _users.firstWhere((u) => u.id == userId);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                              backgroundColor: Colors.purple[100],
                              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                ? Text(
                                    user.fullName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.purple[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  )
                                : null,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _toggleUserSelection(userId),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.fullName,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A2BE2),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final UserProfile user = _filteredUsers[index];
                              final isSelected = _selectedUserIds.contains(user.id);
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                    backgroundColor: isSelected ? Colors.purple[100] : Colors.grey[300],
                                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                      ? Text(
                                          user.fullName.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: isSelected ? Colors.purple[700] : Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                  ),
                                  title: Text(
                                    user.fullName,
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: user.username != null ? Text(
                                    '@${user.username}',
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ) : null,
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF8A2BE2),
                                        )
                                      : const Icon(Icons.check_circle_outline),
                                  onTap: () => _toggleUserSelection(user.id),
                                  selected: isSelected,
                                  selectedTileColor: Colors.purple[50],
                                ),
                              ).animate().fadeIn(duration: 200.ms);
                            },
                          ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _selectedUserIds.isEmpty || _isLoading ? null : _createChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  minimumSize: const Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Start Chat',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Typed API models — match backend response shapes exactly.
class AccountModel {
  AccountModel({required this.id, required this.username, required this.name, required this.type, this.status = 'ACTIVE'});
  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
        id: j['id'], username: j['username'] ?? '', name: j['name'] ?? '', type: j['type'] ?? 'PERSONAL', status: j['status'] ?? 'ACTIVE');
  final String id, username, name, type, status;
}

class PostModel {
  PostModel({required this.id, required this.authorId, this.authorName = '', this.authorUsername = '', this.body, this.visibility = 'PUBLIC', this.likeCount = 0, this.commentCount = 0, this.createdAt});
  factory PostModel.fromJson(Map<String, dynamic> j) => PostModel(
        id: j['id'], authorId: j['authorAccountId'] ?? j['author']?['id'] ?? '',
        authorName: j['author']?['name'] ?? '', authorUsername: j['author']?['username'] ?? '',
        body: j['body'], visibility: j['visibility'] ?? 'PUBLIC',
        likeCount: j['_count']?['reactions'] ?? j['likeCount'] ?? 0,
        commentCount: j['_count']?['comments'] ?? j['commentCount'] ?? 0,
        createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null);
  final String id, authorId, authorName, authorUsername, visibility;
  final String? body;
  final int likeCount, commentCount;
  final DateTime? createdAt;
}

class ConversationModel {
  ConversationModel({required this.id, this.title = '', this.lastMessage, this.lastAt, this.unread = 0, this.isGroup = false});
  factory ConversationModel.fromJson(Map<String, dynamic> j) => ConversationModel(
        id: j['id'], title: j['title'] ?? j['name'] ?? '', lastMessage: j['lastMessage']?['body'],
        lastAt: j['lastMessageAt'] != null ? DateTime.tryParse(j['lastMessageAt']) : null,
        unread: j['unreadCount'] ?? 0, isGroup: j['type'] == 'GROUP');
  final String id, title;
  final String? lastMessage;
  final DateTime? lastAt;
  final int unread;
  final bool isGroup;
}

class MessageModel {
  MessageModel({required this.id, required this.convId, required this.senderId, this.body, this.seq = 0, this.createdAt});
  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
        id: j['id'], convId: j['conversationId'], senderId: j['senderAccountId'], body: j['body'], seq: j['seq'] ?? 0,
        createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null);
  final String id, convId, senderId;
  final String? body;
  final int seq;
  final DateTime? createdAt;
}

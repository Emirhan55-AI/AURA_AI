/// Domain entity representing a comment on a social post
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String username;
  final String? avatarUrl;

  /// Creates a new Comment instance
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.username,
    this.avatarUrl,
  });

  /// Creates a copy of this Comment with the specified fields updated
  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    DateTime? createdAt,
    String? username,
    String? avatarUrl,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment &&
        other.id == id &&
        other.postId == postId &&
        other.userId == userId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.username == username &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      postId.hashCode ^
      userId.hashCode ^
      content.hashCode ^
      createdAt.hashCode ^
      username.hashCode ^
      avatarUrl.hashCode;
}

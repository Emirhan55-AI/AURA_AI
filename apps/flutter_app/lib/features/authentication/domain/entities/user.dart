/// User entity representing an authenticated user in the Aura application
/// This is a domain model that contains the essential user information
class User {
  /// Unique identifier for the user
  final String id;
  
  /// User's email address
  final String email;
  
  /// User's display name (optional)
  final String? displayName;
  
  /// Timestamp when the user was created
  final DateTime? createdAt;
  
  /// Timestamp when the user last signed in
  final DateTime? lastSignInAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
    this.lastSignInAt,
  });

  /// Creates a copy of this User with the given fields replaced with new values
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.createdAt == createdAt &&
        other.lastSignInAt == lastSignInAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        createdAt.hashCode ^
        lastSignInAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, createdAt: $createdAt, lastSignInAt: $lastSignInAt)';
  }
}

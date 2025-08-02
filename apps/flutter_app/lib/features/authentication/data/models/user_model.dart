import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user.dart';

/// Data model for User that extends the domain entity
/// Handles mapping between Supabase User objects and domain User entities
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.createdAt,
    super.lastSignInAt,
  });

  /// Creates a UserModel from a Supabase User object
  factory UserModel.fromSupabaseUser(supabase.User supabaseUser) {
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: supabaseUser.userMetadata?['full_name'] as String?,
      createdAt: supabaseUser.createdAt != null 
          ? DateTime.parse(supabaseUser.createdAt!)
          : null,
      lastSignInAt: supabaseUser.lastSignInAt != null
          ? DateTime.parse(supabaseUser.lastSignInAt!)
          : null,
    );
  }

  /// Creates a UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.parse(json['last_sign_in_at'] as String)
          : null,
    );
  }

  /// Converts UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
    };
  }

  /// Converts UserModel to domain User entity
  User toDomainEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
    );
  }

  /// Creates a copy of this UserModel with the given fields replaced
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}

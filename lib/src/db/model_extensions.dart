import 'package:drift/drift.dart';
import 'database.dart';

// ============================================================================
// MODEL EXTENSIONS - For Supabase Integration
// ============================================================================

// ============================================================================
// USER EXTENSIONS
// ============================================================================

extension UserExtensions on User {
  /// Copy with method
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Convert to Drift Companion
  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      name: Value(name),
      avatarUrl:
          avatarUrl == null && nullToAbsent ? const Value.absent() : Value(avatarUrl),
      bio: Value(bio),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (from Supabase)
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncedAt: null,
      needsSync: false,
    );
  }

  // Helper getters
  String get displayName => name.isEmpty ? email.split('@').first : name;

  String get initials {
    if (name.isEmpty) return email[0].toUpperCase();
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
}

// ============================================================================
// HABIT EXTENSIONS
// ============================================================================

extension HabitExtensions on Habit {
  /// Copy with method
  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    String? frequency,
    int? targetDays,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    bool? isActive,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Convert to Drift Companion
  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      description: Value(description),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent ? const Value.absent() : Value(color),
      frequency: Value(frequency),
      targetDays: Value(targetDays),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      totalCompletions: Value(totalCompletions),
      isActive: Value(isActive),
      isPublic: Value(isPublic),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'target_days': targetDays,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_completions': totalCompletions,
      'is_active': isActive,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (from Supabase)
  static Habit fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      frequency: json['frequency'] as String? ?? 'daily',
      targetDays: json['target_days'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalCompletions: json['total_completions'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isPublic: json['is_public'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncedAt: null,
      needsSync: false,
    );
  }

  // Helper getters
  String get streakText {
    if (currentStreak == 0) return 'No streak';
    if (currentStreak == 1) return '1 day streak 🔥';
    return '$currentStreak days streak 🔥';
  }

  String get frequencyText {
    switch (frequency) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        return '$targetDays ${targetDays == 1 ? 'day' : 'days'} per week';
      case 'custom':
        return 'Custom schedule';
      default:
        return frequency;
    }
  }

  double get completionRate {
    if (totalCompletions == 0) return 0.0;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
    return (totalCompletions / daysSinceCreation).clamp(0.0, 1.0);
  }

  bool get isOnStreak => currentStreak > 0;
  bool get hasLongestStreak => longestStreak > 0;
}

// ============================================================================
// COMPLETION EXTENSIONS
// ============================================================================

extension CompletionExtensions on Completion {
  /// Copy with method
  Completion copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    String? note,
    String? photoUrl,
    String? location,
    int? streakDay,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return Completion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      streakDay: streakDay ?? this.streakDay,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Convert to Drift Companion
  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      userId: Value(userId),
      completedAt: Value(completedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      photoUrl:
          photoUrl == null && nullToAbsent ? const Value.absent() : Value(photoUrl),
      location:
          location == null && nullToAbsent ? const Value.absent() : Value(location),
      streakDay: Value(streakDay),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'note': note,
      'photo_url': photoUrl,
      'location': location,
      'streak_day': streakDay,
    };
  }

  /// Create from JSON (from Supabase)
  static Completion fromJson(Map<String, dynamic> json) {
    return Completion(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      note: json['note'] as String?,
      photoUrl: json['photo_url'] as String?,
      location: json['location'] as String?,
      streakDay: json['streak_day'] as int? ?? 0,
      lastSyncedAt: null,
      needsSync: false,
    );
  }

  // Helper getters
  bool get hasNote => note != null && note!.isNotEmpty;
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasLocation => location != null && location!.isNotEmpty;

  bool get isToday {
    final now = DateTime.now();
    return completedAt.year == now.year &&
        completedAt.month == now.month &&
        completedAt.day == now.day;
  }
}

// ============================================================================
// FRIEND EXTENSIONS
// ============================================================================

extension FriendExtensions on Friend {
  /// Copy with method
  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (from Supabase)
  static Friend fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendId: json['friend_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncedAt: null,
      needsSync: false,
    );
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isBlocked => status == 'blocked';
}

// ============================================================================
// POST EXTENSIONS
// ============================================================================

extension PostExtensions on Post {
  /// Copy with method
  Post copyWith({
    String? id,
    String? userId,
    String? habitId,
    String? completionId,
    String? content,
    String? photoUrl,
    int? likesCount,
    int? commentsCount,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      completionId: completionId ?? this.completionId,
      content: content ?? this.content,
      photoUrl: photoUrl ?? this.photoUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_id': habitId,
      'completion_id': completionId,
      'content': content,
      'photo_url': photoUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON (from Supabase)
  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String?,
      completionId: json['completion_id'] as String?,
      content: json['content'] as String,
      photoUrl: json['photo_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSyncedAt: null,
      needsSync: false,
    );
  }

  // Helper getters
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasHabit => habitId != null;
  bool get hasCompletion => completionId != null;
  bool get hasEngagement => likesCount > 0 || commentsCount > 0;

  String get likesText {
    if (likesCount == 0) return 'No likes';
    if (likesCount == 1) return '1 like';
    return '$likesCount likes';
  }

  String get commentsText {
    if (commentsCount == 0) return 'No comments';
    if (commentsCount == 1) return '1 comment';
    return '$commentsCount comments';
  }
}

// ============================================================================
// NOTIFICATION EXTENSIONS
// ============================================================================

extension NotificationExtensions on Notification {
  /// Copy with method
  Notification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    String? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper getters
  bool get hasData => data != null && data!.isNotEmpty;
  bool get isUnread => !isRead;

  String get typeIcon {
    switch (type) {
      case 'friend_request':
        return '👥';
      case 'like':
        return '❤️';
      case 'comment':
        return '💬';
      case 'streak_milestone':
        return '🔥';
      default:
        return '🔔';
    }
  }
}

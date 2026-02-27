import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============================================================================
// TABLE DEFINITIONS
// ============================================================================

/// Users table - Syncs with Supabase auth.users
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get bio => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Supabase sync
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Habits table
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get frequency => text().withDefault(const Constant('daily'))(); // daily, weekly, custom
  IntColumn get targetDays => integer().withDefault(const Constant(1))(); // per week
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  IntColumn get totalCompletions => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Supabase sync
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Habit Completions table (with BeReal-style photos)
class Completions extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get photoUrl => text().nullable()(); // BeReal-style photo
  TextColumn get location => text().nullable()();
  IntColumn get streakDay => integer().withDefault(const Constant(0))();
  
  // Supabase sync
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, completedAt}, // One completion per habit per day
  ];
}

/// Friends/Followers table (many-to-many)
class Friends extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get friendId => text()();
  TextColumn get status => text()(); // pending, accepted, blocked
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Supabase sync
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Social Feed Posts table
class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get habitId => text().nullable()();
  TextColumn get completionId => text().nullable()();
  TextColumn get content => text()();
  TextColumn get photoUrl => text().nullable()();
  IntColumn get likesCount => integer().withDefault(const Constant(0))();
  IntColumn get commentsCount => integer().withDefault(const Constant(0))();
  BoolColumn get isPublic => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  
  // Supabase sync
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Likes table
class Likes extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime()();
  
  // Supabase sync
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {postId, userId}, // One like per user per post
  ];
}

/// Comments table
class Comments extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text()();
  TextColumn get userId => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  
  // Supabase sync
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Notifications table
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()(); // friend_request, like, comment, streak_milestone
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get data => text().nullable()(); // JSON data
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// DATABASE CLASS
// ============================================================================

@DriftDatabase(tables: [
  Users,
  Habits,
  Completions,
  Friends,
  Posts,
  Likes,
  Comments,
  Notifications,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle schema migrations here
        // Example for version 2:
        // if (from < 2) {
        //   await m.addColumn(habits, habits.newColumn);
        // }
      },
    );
  }

  // ============================================================================
  // USER QUERIES
  // ============================================================================

  /// Get current user
  Future<User?> getCurrentUser() {
    return select(users).getSingleOrNull();
  }

  /// Save user (from Supabase)
  Future<int> upsertUser(UsersCompanion user) {
    return into(users).insertOnConflictUpdate(user);
  }

  /// Update user sync status
  Future<int> markUserSynced(String userId) {
    return (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        lastSyncedAt: Value(DateTime.now()),
        needsSync: const Value(false),
      ),
    );
  }

  // ============================================================================
  // HABIT QUERIES
  // ============================================================================

  /// Get all active habits for user
  Future<List<Habit>> getAllHabits(String userId) {
    return (select(habits)
          ..where((h) => h.userId.equals(userId))
          ..where((h) => h.isActive.equals(true))
          ..orderBy([(h) => OrderingTerm.desc(h.createdAt)]))
        .get();
  }

  /// Get single habit
  Future<Habit?> getHabitById(String habitId) {
    return (select(habits)..where((h) => h.id.equals(habitId)))
        .getSingleOrNull();
  }

  /// Upsert habit
  Future<int> upsertHabit(HabitsCompanion habit) {
    return into(habits).insertOnConflictUpdate(habit);
  }

  /// Soft delete habit
  Future<int> deleteHabit(String habitId) {
    return (update(habits)..where((h) => h.id.equals(habitId))).write(
      HabitsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Get habits that need sync
  Future<List<Habit>> getHabitsNeedingSync() {
    return (select(habits)..where((h) => h.needsSync.equals(true))).get();
  }

  // ============================================================================
  // COMPLETION QUERIES
  // ============================================================================

  /// Get completions for a habit
  Future<List<Completion>> getHabitCompletions(
    String habitId, {
    int limit = 30,
  }) {
    return (select(completions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)])
          ..limit(limit))
        .get();
  }

  /// Check if habit completed today
  Future<bool> isHabitCompletedToday(String habitId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await (select(completions)
          ..where((c) => c.habitId.equals(habitId))
          ..where((c) => c.completedAt.isBiggerOrEqualValue(startOfDay))
          ..where((c) => c.completedAt.isSmallerThanValue(endOfDay)))
        .getSingleOrNull();

    return result != null;
  }

  /// Get today's completion for habit
  Future<Completion?> getTodayCompletion(String habitId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(completions)
          ..where((c) => c.habitId.equals(habitId))
          ..where((c) => c.completedAt.isBiggerOrEqualValue(startOfDay))
          ..where((c) => c.completedAt.isSmallerThanValue(endOfDay)))
        .getSingleOrNull();
  }

  /// Add completion
  Future<int> addCompletion(CompletionsCompanion completion) {
    return into(completions).insert(completion);
  }

  /// Delete completion
  Future<int> deleteCompletion(String completionId) {
    return (delete(completions)..where((c) => c.id.equals(completionId))).go();
  }

  /// Get completions that need sync
  Future<List<Completion>> getCompletionsNeedingSync() {
    return (select(completions)..where((c) => c.needsSync.equals(true))).get();
  }

  // ============================================================================
  // FRIEND QUERIES
  // ============================================================================

  /// Get all accepted friends for user
  Future<List<Friend>> getFriends(String userId) {
    return (select(friends)
          ..where((f) =>
              f.userId.equals(userId) | f.friendId.equals(userId))
          ..where((f) => f.status.equals('accepted')))
        .get();
  }

  /// Get pending friend requests
  Future<List<Friend>> getPendingRequests(String userId) {
    return (select(friends)
          ..where((f) => f.friendId.equals(userId))
          ..where((f) => f.status.equals('pending')))
        .get();
  }

  /// Add friend request
  Future<int> addFriendRequest(FriendsCompanion friend) {
    return into(friends).insert(friend);
  }

  /// Accept friend request
  Future<int> acceptFriendRequest(String friendshipId) {
    return (update(friends)..where((f) => f.id.equals(friendshipId))).write(
      FriendsCompanion(
        status: const Value('accepted'),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Check if users are friends
  Future<bool> areFriends(String userId, String friendId) async {
    final result = await (select(friends)
          ..where((f) =>
              (f.userId.equals(userId) & f.friendId.equals(friendId)) |
              (f.userId.equals(friendId) & f.friendId.equals(userId)))
          ..where((f) => f.status.equals('accepted')))
        .getSingleOrNull();

    return result != null;
  }

  // ============================================================================
  // POST QUERIES
  // ============================================================================

  /// Get social feed posts
  Future<List<Post>> getFeedPosts({int limit = 20, int offset = 0}) {
    return (select(posts)
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get user's posts
  Future<List<Post>> getUserPosts(String userId, {int limit = 20}) {
    return (select(posts)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Add post
  Future<int> addPost(PostsCompanion post) {
    return into(posts).insert(post);
  }

  /// Get posts that need sync
  Future<List<Post>> getPostsNeedingSync() {
    return (select(posts)..where((p) => p.needsSync.equals(true))).get();
  }

  // ============================================================================
  // LIKE QUERIES
  // ============================================================================

  /// Check if user liked post
  Future<bool> hasUserLikedPost(String userId, String postId) async {
    final result = await (select(likes)
          ..where((l) => l.userId.equals(userId))
          ..where((l) => l.postId.equals(postId)))
        .getSingleOrNull();
    return result != null;
  }

  /// Toggle like
  Future<void> toggleLike(String userId, String postId, String likeId) async {
    final exists = await hasUserLikedPost(userId, postId);
    
    if (exists) {
      // Unlike
      await (delete(likes)
            ..where((l) => l.userId.equals(userId))
            ..where((l) => l.postId.equals(postId)))
          .go();
      
      // Decrement count
      final post = await (select(posts)..where((p) => p.id.equals(postId)))
          .getSingleOrNull();
      if (post != null) {
        await (update(posts)..where((p) => p.id.equals(postId))).write(
          PostsCompanion(
            likesCount: Value(post.likesCount > 0 ? post.likesCount - 1 : 0),
          ),
        );
      }
    } else {
      // Like
      await into(likes).insert(
        LikesCompanion(
          id: Value(likeId),
          postId: Value(postId),
          userId: Value(userId),
          createdAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      
      // Increment count
      final post = await (select(posts)..where((p) => p.id.equals(postId)))
          .getSingleOrNull();
      if (post != null) {
        await (update(posts)..where((p) => p.id.equals(postId))).write(
          PostsCompanion(
            likesCount: Value(post.likesCount + 1),
          ),
        );
      }
    }
  }

  // ============================================================================
  // COMMENT QUERIES
  // ============================================================================

  /// Get comments for post
  Future<List<Comment>> getPostComments(String postId, {int limit = 50}) {
    return (select(comments)
          ..where((c) => c.postId.equals(postId))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Add comment
  Future<int> addComment(CommentsCompanion comment) async {
    final id = await into(comments).insert(comment);
    
    // Increment post comment count
    final postId = comment.postId.value;
    final post = await (select(posts)..where((p) => p.id.equals(postId)))
        .getSingleOrNull();
    if (post != null) {
      await (update(posts)..where((p) => p.id.equals(postId))).write(
        PostsCompanion(
          commentsCount: Value(post.commentsCount + 1),
        ),
      );
    }
    
    return id;
  }

  // ============================================================================
  // NOTIFICATION QUERIES
  // ============================================================================

  /// Get unread notifications
  Future<List<Notification>> getUnreadNotifications(String userId) {
    return (select(notifications)
          ..where((n) => n.userId.equals(userId))
          ..where((n) => n.isRead.equals(false))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .get();
  }

  /// Get all notifications
  Future<List<Notification>> getAllNotifications(
    String userId, {
    int limit = 50,
  }) {
    return (select(notifications)
          ..where((n) => n.userId.equals(userId))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Mark notification as read
  Future<int> markNotificationRead(String notificationId) {
    return (update(notifications)..where((n) => n.id.equals(notificationId)))
        .write(const NotificationsCompanion(isRead: Value(true)));
  }

  /// Mark all notifications as read
  Future<int> markAllNotificationsRead(String userId) {
    return (update(notifications)..where((n) => n.userId.equals(userId)))
        .write(const NotificationsCompanion(isRead: Value(true)));
  }

  // ============================================================================
  // ANALYTICS QUERIES
  // ============================================================================

  /// Get completion stats for date range
  Future<int> getCompletionCount(
    String habitId,
    DateTime start,
    DateTime end,
  ) async {
    final result = await (selectOnly(completions)
          ..addColumns([completions.id.count()])
          ..where(completions.habitId.equals(habitId))
          ..where(completions.completedAt.isBiggerOrEqualValue(start))
          ..where(completions.completedAt.isSmallerThanValue(end)))
        .getSingle();

    return result.read(completions.id.count()) ?? 0;
  }

  /// Get current streak for habit
  Future<int> calculateCurrentStreak(String habitId) async {
    final allCompletions = await (select(completions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .get();

    if (allCompletions.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final completion in allCompletions) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );

      if (lastDate == null) {
        // First completion
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));

        if (completionDate == todayDate || completionDate == yesterday) {
          streak = 1;
          lastDate = completionDate;
        } else {
          break; // Streak broken
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (completionDate == expectedDate) {
          streak++;
          lastDate = completionDate;
        } else {
          break; // Streak broken
        }
      }
    }

    return streak;
  }

  // ============================================================================
  // CLEAR DATA (for logout)
  // ============================================================================

  Future<void> clearAllData() async {
    await delete(notifications).go();
    await delete(comments).go();
    await delete(likes).go();
    await delete(posts).go();
    await delete(friends).go();
    await delete(completions).go();
    await delete(habits).go();
    await delete(users).go();
  }

  /// Clear only cached data (keep user data)
  Future<void> clearCachedData() async {
    await delete(posts).go();
    await delete(notifications).go();
  }
}

// ============================================================================
// DATABASE CONNECTION
// ============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'habitstack.db'));
    return NativeDatabase(file);
  });
}

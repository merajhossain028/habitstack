import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../api/supabase_service.dart';
import '../db/database.dart';
import '../utils/logger/logger_helper.dart';
import 'package:drift/drift.dart';  

const uuid = Uuid();

// ============================================================================
// PROVIDERS
// ============================================================================

/// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Supabase service provider
final supabaseProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// Connectivity provider (for offline detection)
final connectivityProvider = StreamProvider<bool>((ref) async* {
  // Simple connectivity check - can be enhanced with connectivity_plus
  yield true; // Assume online initially
  
  // Listen to auth state changes as a proxy for connectivity
  await for (final state in SupabaseService.instance.authStateChanges) {
    yield state.session != null;
  }
});

// ============================================================================
// HABIT REPOSITORY
// ============================================================================

/// Habit Repository Interface
abstract class IHabitRepository {
  Future<List<Habit>> getAllHabits(String userId);
  Future<Habit?> getHabitById(String habitId);
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String habitId);
  Future<bool> isHabitCompletedToday(String habitId);
  Future<void> toggleHabitCompletion(String habitId, String userId);
  Future<void> syncHabits(String userId);
}

/// Combined Repository with Offline-First Strategy
class HabitRepository implements IHabitRepository {
  final AppDatabase _db;
  final SupabaseService _supabase;

  HabitRepository(this._db, this._supabase);

  @override
  Future<List<Habit>> getAllHabits(String userId) async {
    try {
      // Try to sync first (background)
      syncHabits(userId).catchError((e) {
        log.w('Sync failed, using local cache: $e');
      });

      // Return local data immediately
      return await _db.getAllHabits(userId);
    } catch (e) {
      log.e('Get all habits error: $e');
      rethrow;
    }
  }

  @override
  Future<Habit?> getHabitById(String habitId) async {
    return await _db.getHabitById(habitId);
  }

  @override
  Future<void> createHabit(Habit habit) async {
    // Save locally first (optimistic update)
    await _db.upsertHabit(habit.toCompanion(false));

    // Sync to Supabase in background
    try {
      final habitData = {
        'id': habit.id,
        'user_id': habit.userId,
        'name': habit.name,
        'description': habit.description,
        'icon': habit.icon,
        'color': habit.color,
        'frequency': habit.frequency,
        'target_days': habit.targetDays,
        'current_streak': habit.currentStreak,
        'longest_streak': habit.longestStreak,
        'total_completions': habit.totalCompletions,
        'is_active': habit.isActive,
        'is_public': habit.isPublic,
        'created_at': habit.createdAt.toIso8601String(),
        'updated_at': habit.updatedAt.toIso8601String(),
      };

      await _supabase.createHabit(habitData);

      // Mark as synced
      await _db.markUserSynced(habit.userId);

      log.i('Habit synced to Supabase: ${habit.id}');
    } catch (e) {
      log.e('Failed to sync habit to Supabase: $e');
      // Mark for later sync
      await _db.upsertHabit(
        habit.toCompanion(false).copyWith(needsSync: const Value(true)),
      );
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    // Update locally
    final updated = habit.copyWith(
      updatedAt: DateTime.now(),
      needsSync: true,
    );
    await _db.upsertHabit(updated.toCompanion(false));

    // Sync to Supabase
    try {
      final updates = {
        'name': habit.name,
        'description': habit.description,
        'icon': habit.icon,
        'color': habit.color,
        'frequency': habit.frequency,
        'target_days': habit.targetDays,
        'is_public': habit.isPublic,
      };

      await _supabase.updateHabit(habitId: habit.id, updates: updates);

      // Mark as synced
      await _db.upsertHabit(
        updated.toCompanion(false).copyWith(
              needsSync: const Value(false),
              lastSyncedAt: Value(DateTime.now()),
            ),
      );

      log.i('Habit updated and synced: ${habit.id}');
    } catch (e) {
      log.e('Failed to sync habit update: $e');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    // Delete locally
    await _db.deleteHabit(habitId);

    // Delete on Supabase
    try {
      await _supabase.deleteHabit(habitId);
      log.i('Habit deleted from Supabase: $habitId');
    } catch (e) {
      log.e('Failed to delete habit from Supabase: $e');
    }
  }

  @override
  Future<bool> isHabitCompletedToday(String habitId) async {
    return await _db.isHabitCompletedToday(habitId);
  }

  @override
  Future<void> toggleHabitCompletion(String habitId, String userId) async {
    final isCompleted = await isHabitCompletedToday(habitId);

    if (isCompleted) {
      // Remove completion
      final completion = await _db.getTodayCompletion(habitId);
      if (completion != null) {
        await _db.deleteCompletion(completion.id);

        // Update habit stats
        final habit = await getHabitById(habitId);
        if (habit != null) {
          final updatedHabit = habit.copyWith(
            currentStreak: habit.currentStreak > 0 ? habit.currentStreak - 1 : 0,
            totalCompletions: habit.totalCompletions > 0
                ? habit.totalCompletions - 1
                : 0,
            needsSync: true,
          );
          await updateHabit(updatedHabit);
        }

        // Sync deletion to Supabase
        try {
          await _supabase.deleteCompletion(completion.id);
        } catch (e) {
          log.e('Failed to delete completion from Supabase: $e');
        }
      }
    } else {
      // Add completion
      final completionId = uuid.v4();
      final completion = CompletionsCompanion.insert(
        id: completionId,
        habitId: habitId,
        userId: userId,
        completedAt: DateTime.now(),
        needsSync: const Value(true),
      );
      await _db.addCompletion(completion);

      // Update habit stats
      final habit = await getHabitById(habitId);
      if (habit != null) {
        // Calculate new streak
        final newStreak = await _db.calculateCurrentStreak(habitId);
        final updatedHabit = habit.copyWith(
          currentStreak: newStreak,
          longestStreak:
              newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
          totalCompletions: habit.totalCompletions + 1,
          updatedAt: DateTime.now(),
          needsSync: true,
        );
        await updateHabit(updatedHabit);
      }

      // Sync to Supabase
      try {
        final completionData = {
          'id': completionId,
          'habit_id': habitId,
          'user_id': userId,
          'completed_at': DateTime.now().toIso8601String(),
        };
        await _supabase.addCompletion(completionData);

        // Mark as synced
        await _db.upsertHabit(
          habit!.toCompanion(false).copyWith(
                needsSync: const Value(false),
                lastSyncedAt: Value(DateTime.now()),
              ),
        );
      } catch (e) {
        log.e('Failed to sync completion: $e');
      }
    }
  }

  @override
  Future<void> syncHabits(String userId) async {
    try {
      // Fetch from Supabase
      final remoteHabits = await _supabase.getHabits(userId);

      // Update local database
      for (final habitData in remoteHabits) {
        final habit = Habit(
          id: habitData['id'] as String,
          userId: habitData['user_id'] as String,
          name: habitData['name'] as String,
          description: habitData['description'] as String? ?? '',
          icon: habitData['icon'] as String?,
          color: habitData['color'] as String?,
          frequency: habitData['frequency'] as String? ?? 'daily',
          targetDays: habitData['target_days'] as int? ?? 1,
          currentStreak: habitData['current_streak'] as int? ?? 0,
          longestStreak: habitData['longest_streak'] as int? ?? 0,
          totalCompletions: habitData['total_completions'] as int? ?? 0,
          isActive: habitData['is_active'] as bool? ?? true,
          isPublic: habitData['is_public'] as bool? ?? false,
          createdAt: DateTime.parse(habitData['created_at'] as String),
          updatedAt: DateTime.parse(habitData['updated_at'] as String),
          lastSyncedAt: DateTime.now(),
          needsSync: false,
        );

        await _db.upsertHabit(habit.toCompanion(false));
      }

      // Push local changes that need sync
      final needsSync = await _db.getHabitsNeedingSync();
      for (final habit in needsSync) {
        try {
          final updates = {
            'name': habit.name,
            'current_streak': habit.currentStreak,
            'longest_streak': habit.longestStreak,
            'total_completions': habit.totalCompletions,
          };
          await _supabase.updateHabit(habitId: habit.id, updates: updates);

          // Mark as synced
          await _db.upsertHabit(
            habit.toCompanion(false).copyWith(
                  needsSync: const Value(false),
                  lastSyncedAt: Value(DateTime.now()),
                ),
          );
        } catch (e) {
          log.w('Failed to push habit ${habit.id}: $e');
        }
      }

      log.i('Habits synced successfully');
    } catch (e) {
      log.e('Sync habits error: $e');
      rethrow;
    }
  }
}

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// Habit Repository Provider
final habitRepositoryProvider = Provider<IHabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseProvider);
  return HabitRepository(db, supabase);
});

// ============================================================================
// USER REPOSITORY
// ============================================================================

/// User Repository Interface
abstract class IUserRepository {
  Future<User?> getCurrentUser();
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  });
  Future<void> syncUser(String userId);
}

/// User Repository Implementation
class UserRepository implements IUserRepository {
  final AppDatabase _db;
  final SupabaseService _supabase;

  UserRepository(this._db, this._supabase);

  @override
  Future<User?> getCurrentUser() async {
    return await _db.getCurrentUser();
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    // Update locally
    final user = await getCurrentUser();
    if (user != null) {
      final updated = UsersCompanion(
        id: Value(userId),
        name: name != null ? Value(name) : Value(user.name),
        bio: bio != null ? Value(bio) : Value(user.bio),
        avatarUrl: avatarUrl != null ? Value(avatarUrl) : Value(user.avatarUrl),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      );
      await _db.upsertUser(updated);
    }

    // Sync to Supabase
    try {
      await _supabase.updateUserProfile(
        userId: userId,
        name: name,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      // Mark as synced
      await _db.markUserSynced(userId);
    } catch (e) {
      log.e('Failed to sync user profile: $e');
    }
  }

  @override
  Future<void> syncUser(String userId) async {
    try {
      final userData = await _supabase.getUserProfile(userId);
      if (userData != null) {
        final user = UsersCompanion(
          id: Value(userData['id'] as String),
          email: Value(userData['email'] as String),
          name: Value(userData['name'] as String),
          bio: Value(userData['bio'] as String? ?? ''),
          avatarUrl: Value(userData['avatar_url'] as String?),
          createdAt: Value(DateTime.parse(userData['created_at'] as String)),
          updatedAt: Value(DateTime.parse(userData['updated_at'] as String)),
          lastSyncedAt: Value(DateTime.now()),
          needsSync: const Value(false),
        );
        await _db.upsertUser(user);
      }
    } catch (e) {
      log.e('Sync user error: $e');
    }
  }
}

/// User Repository Provider
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseProvider);
  return UserRepository(db, supabase);
});

// ============================================================================
// SYNC SERVICE
// ============================================================================

/// Sync Service for background synchronization
class SyncService {
  final AppDatabase _db;
  final SupabaseService _supabase;

  SyncService(this._db, this._supabase);

  /// Sync all data
  Future<void> syncAll(String userId) async {
    try {
      log.i('Starting full sync...');

      // Sync habits
      await _syncHabits(userId);

      // Sync completions
      await _syncCompletions();

      // Sync friends
      await _syncFriends(userId);

      log.i('Full sync completed');
    } catch (e) {
      log.e('Full sync error: $e');
    }
  }

  Future<void> _syncHabits(String userId) async {
    final needsSync = await _db.getHabitsNeedingSync();
    for (final habit in needsSync) {
      try {
        final updates = {
          'name': habit.name,
          'current_streak': habit.currentStreak,
          'longest_streak': habit.longestStreak,
          'total_completions': habit.totalCompletions,
        };
        await _supabase.updateHabit(habitId: habit.id, updates: updates);

        await _db.upsertHabit(
          habit.toCompanion(false).copyWith(
                needsSync: const Value(false),
                lastSyncedAt: Value(DateTime.now()),
              ),
        );
      } catch (e) {
        log.w('Failed to sync habit ${habit.id}: $e');
      }
    }
  }

  Future<void> _syncCompletions() async {
    final needsSync = await _db.getCompletionsNeedingSync();
    for (final completion in needsSync) {
      try {
        final data = {
          'id': completion.id,
          'habit_id': completion.habitId,
          'user_id': completion.userId,
          'completed_at': completion.completedAt.toIso8601String(),
          'note': completion.note,
          'photo_url': completion.photoUrl,
        };
        await _supabase.addCompletion(data);
      } catch (e) {
        log.w('Failed to sync completion ${completion.id}: $e');
      }
    }
  }

  Future<void> _syncFriends(String userId) async {
    try {
      final remoteFriends = await _supabase.getFriends(userId);
      // Update local database...
    } catch (e) {
      log.w('Failed to sync friends: $e');
    }
  }
}

/// Sync Service Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseProvider);
  return SyncService(db, supabase);
});

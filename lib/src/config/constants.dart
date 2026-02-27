/// App-wide constants
library;

// ============================================================================
// APP INFO
// ============================================================================

const String appName = 'HabitStack';

// ============================================================================
// SUPABASE CONFIG
// ============================================================================

/// Supabase Project URL - Replace with your project URL
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://qxjqtirmwykngbsjhdle.supabase.co',
);

/// Supabase Anon Key - Replace with your anon key
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4anF0aXJtd3lrbmdic2poZGxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxNTEwMzUsImV4cCI6MjA4NzcyNzAzNX0.Hzq4j-KqG_5GAeKSH5o3lkM5_n1m1ZmMIFBLRivXz5E',
);

// ============================================================================
// APP LIMITS
// ============================================================================

const int maxHabits = 50;
const int maxHabitsFreeTier = 5;
const int maxPhotoSizeMB = 5;
const int maxBioLength = 200;
const int maxHabitNameLength = 100;

// ============================================================================
// STORAGE
// ============================================================================

const String databaseName = 'habitstack.db';

// ============================================================================
// TIMING
// ============================================================================

const Duration syncInterval = Duration(minutes: 5);
const Duration sessionTimeout = Duration(hours: 24);
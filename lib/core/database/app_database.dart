import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─────────────────────────────────────────────
// Tables
// ─────────────────────────────────────────────

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().withDefault(const Constant('me'))(); // Current user ID
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  IntColumn get category => integer()(); // Enum index
  IntColumn get frequency => integer()(); // Enum index
  TextColumn get customDays => text()(); // JSON string
  IntColumn get targetCount => integer().withDefault(const Constant(1))();
  IntColumn get currentCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get reminderTime => dateTime().nullable()();
  IntColumn get streakCount => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSharedWithPartner =>
      boolean().withDefault(const Constant(false))();
  IntColumn get iconBg => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get xpReward => integer().withDefault(const Constant(50))();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitLogs extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DuoSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userAId => text()();
  TextColumn get userBId => text().nullable()();
  TextColumn get sharedPlantId => text()();
  TextColumn get inviteCode => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Plants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  IntColumn get stage => integer()(); // 0=Seed 1=Sprout 2=Bud 3=Bloom 4=Garden
  RealColumn get growthPercent => real().withDefault(const Constant(0.0))();
  TextColumn get duoSessionId =>
      text().nullable().references(DuoSessions, #id)();
  TextColumn get ownerId =>
      text().withDefault(const Constant('me'))(); // solo garden owner
  IntColumn get waterCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWateredAt => dateTime().nullable()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().withDefault(const Constant('me'))(); // Current user ID
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get xpReward => integer().withDefault(const Constant(20))();
  IntColumn get bloomReward => integer().withDefault(const Constant(5))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get estimatedMinutes => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()(); // The journal entry text body
  TextColumn get mood => text()(); // emoji string: '😊' '😔' etc.
  IntColumn get moodScore => integer().withDefault(const Constant(3))(); // 1–5
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ShopItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  IntColumn get price => integer()();
  TextColumn get category =>
      text()(); // 'pet_accessory' | 'plant_skin' | 'adventure_key'
  BoolColumn get owned => boolean().withDefault(const Constant(false))();
  BoolColumn get equipped => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class AdventureLands extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  TextColumn get description => text()();
  IntColumn get requiredLevel => integer()();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();
  RealColumn get progress => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────
// Database
// ─────────────────────────────────────────────

@DriftDatabase(
  tables: [
    Habits,
    HabitLogs,
    DuoSessions,
    Plants,
    Tasks,
    JournalEntries,
    ShopItems,
    AdventureLands,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedShopItems();
      await _seedAdventureLands();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(tasks);
        await m.createTable(journalEntries);
        await m.createTable(shopItems);
        await m.createTable(adventureLands);
        await m.addColumn(habits, habits.xpReward);
        await m.addColumn(habits, habits.lastCompletedAt);
        await m.addColumn(plants, plants.ownerId);
        await _seedShopItems();
        await _seedAdventureLands();
      }
      if (from < 3) {
        // SQLite cannot ALTER COLUMN to remove NOT NULL,
        // so we drop + recreate the plants table with the
        // correct nullable duo_session_id column.
        await customStatement('DROP TABLE IF EXISTS plants');
        await m.createTable(plants);
      }
      if (from < 4) {
        // Add user_id column to habits table for user data isolation
        try {
          await m.addColumn(habits, habits.userId);
        } catch (e) {
          if (!e.toString().contains('duplicate column name')) {
            rethrow;
          }
        }
        // Migrate existing habits to have 'me' as user_id
        await customStatement("UPDATE habits SET user_id = 'me' WHERE user_id IS NULL");
      }
      if (from < 5) {
        // Add user_id column to tasks table for user data isolation
        try {
          await m.addColumn(tasks, tasks.userId);
        } catch (e) {
          if (!e.toString().contains('duplicate column name')) {
            rethrow;
          }
        }
        // Migrate existing tasks to have 'me' as user_id
        await customStatement("UPDATE tasks SET user_id = 'me' WHERE user_id IS NULL");
      }
      if (from < 6) {
        await _seedShopItems();
      }
    },
  );

  // ── Habit Queries ──────────────────────────

  Future<List<Habit>> getAllHabits(String userId) =>
      (select(habits)
        ..where((t) => t.isArchived.equals(false))
        ..where((t) => t.userId.equals(userId)))
      .get();

  Future<int> insertHabit(Habit habit) {
    // Ensure habit has userId
    final habitWithUser = habit.copyWith(userId: habit.userId);
    return into(habits).insert(habitWithUser);
  }

  Future updateHabit(Habit habit) => update(habits).replace(habit);

  Future archiveHabit(String id) =>
      (update(habits)..where((t) => t.id.equals(id))).write(
        const HabitsCompanion(isArchived: Value(true)),
      );

  // ── HabitLog Queries ───────────────────────

  Future<int> insertLog(HabitLog log) => into(habitLogs).insert(log);

  Future<List<HabitLog>> getLogsForHabit(String habitId) =>
      (select(habitLogs)..where((t) => t.habitId.equals(habitId))).get();

  Future<List<HabitLog>> getLogsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(habitLogs)..where(
          (t) =>
              t.completedAt.isBiggerOrEqualValue(start) &
              t.completedAt.isSmallerThanValue(end),
        ))
        .get();
  }

  Future<List<HabitLog>> getLogsForHabitSince(String habitId, DateTime since) =>
      (select(habitLogs)..where(
            (t) =>
                t.habitId.equals(habitId) &
                t.completedAt.isBiggerOrEqualValue(since),
          ))
          .get();

  // ── Duo Queries ────────────────────────────

  Future<DuoSession?> getActiveSession() =>
      (select(duoSessions)
            ..where((t) => t.isActive.equals(true))
            ..limit(1))
          .getSingleOrNull();

  /// Deactivates all sessions (useful for cleanup or logout)
  Future<void> deactivateAllSessions() => update(
    duoSessions,
  ).write(const DuoSessionsCompanion(isActive: Value(false)));

  Future<int> insertSession(DuoSession session) =>
      into(duoSessions).insertOnConflictUpdate(session);

  // ── Plant Queries ──────────────────────────

  Future<Plant?> getPlantForDuo(String duoSessionId) =>
      (select(plants)..where(
            (t) =>
                t.duoSessionId.equals(duoSessionId) &
                t.stage.isSmallerThanValue(4),
          ))
          .getSingleOrNull();

  Future<Plant?> getActiveSoloPlant() =>
      (select(plants)
            ..where(
              (t) => t.ownerId.equals('me') & t.stage.isSmallerThanValue(4),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<Plant>> getSoloPlants() =>
      (select(plants)..where((t) => t.ownerId.equals('me'))).get();

  Future<int> insertPlant(Plant plant) =>
      into(plants).insertOnConflictUpdate(plant);
  Future updatePlant(Plant plant) => update(plants).replace(plant);
  Future<List<Plant>> getAllPlants() => select(plants).get();

  // ── Task Queries ───────────────────────────

  Future<List<Task>> getActiveTasks(String userId) =>
      (select(tasks)
            ..where((t) => t.completed.equals(false))
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<List<Task>> getCompletedTasks(String userId) =>
      (select(tasks)
            ..where((t) => t.completed.equals(true))
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .get();

  Future<int> insertTask(Task task) {
    final taskWithUser = task.copyWith(userId: task.userId);
    return into(tasks).insert(taskWithUser);
  }

  Future updateTask(Task task) {
    final taskWithUser = task.copyWith(userId: task.userId);
    return update(tasks).replace(taskWithUser);
  }

  Future deleteTask(String id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();

  // ── Journal Queries ────────────────────────

  Future<JournalEntry?> getEntryForToday() {
    final start = DateTime.now();
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return (select(journalEntries)..where(
          (t) =>
              t.createdAt.isBiggerOrEqualValue(dayStart) &
              t.createdAt.isSmallerThanValue(dayEnd),
        ))
        .getSingleOrNull();
  }

  Future<List<JournalEntry>> getEntriesForMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return (select(journalEntries)
          ..where(
            (t) =>
                t.createdAt.isBiggerOrEqualValue(start) &
                t.createdAt.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<JournalEntry>> getRecentEntries({int limit = 30}) =>
      (select(journalEntries)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<List<JournalEntry>> getAllJournalEntries() => (select(
    journalEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<int> insertJournalEntry(JournalEntry entry) =>
      into(journalEntries).insertOnConflictUpdate(entry);

  Future updateJournalEntry(JournalEntry entry) =>
      update(journalEntries).replace(entry);

  // ── Shop Queries ───────────────────────────

  Future<List<ShopItem>> getAllShopItems() => select(shopItems).get();

  Future<List<ShopItem>> getShopItemsByCategory(String category) =>
      (select(shopItems)..where((t) => t.category.equals(category))).get();

  Future<List<ShopItem>> getOwnedItems() =>
      (select(shopItems)..where((t) => t.owned.equals(true))).get();

  Future<List<ShopItem>> getEquippedItems() =>
      (select(shopItems)..where((t) => t.equipped.equals(true))).get();

  Future updateShopItem(ShopItem item) => update(shopItems).replace(item);

  Future equipShopItem(String id, String category) => transaction(() async {
    // Unequip all items in this category
    await (update(shopItems)..where((t) => t.category.equals(category))).write(
      const ShopItemsCompanion(equipped: Value(false)),
    );
    // Equip this specific item
    await (update(shopItems)..where((t) => t.id.equals(id))).write(
      const ShopItemsCompanion(equipped: Value(true)),
    );
  });

  Future unequipShopItem(String id) =>
      (update(shopItems)..where((t) => t.id.equals(id))).write(
        const ShopItemsCompanion(equipped: Value(false)),
      );

  // ── Adventure Queries ──────────────────────

  Future<List<AdventureLand>> getAllLands() => (select(
    adventureLands,
  )..orderBy([(t) => OrderingTerm.asc(t.requiredLevel)])).get();

  Future updateLand(AdventureLand land) => update(adventureLands).replace(land);

  // ── Seed Data ──────────────────────────────

  Future<void> _seedShopItems() async {
    final items = [
      // Pet Accessories
      ShopItem(
        id: 'acc_bow',
        name: 'Pink Bow',
        emoji: '🎀',
        price: 80,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_crown',
        name: 'Flower Crown',
        emoji: '👑',
        price: 200,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_hat',
        name: 'Sun Hat',
        emoji: '👒',
        price: 120,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_scarf',
        name: 'Cozy Scarf',
        emoji: '🧣',
        price: 100,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_glasses',
        name: 'Star Glasses',
        emoji: '🕶️',
        price: 150,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_wings',
        name: 'Fairy Wings',
        emoji: '🦋',
        price: 300,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_ribbon',
        name: 'Silk Ribbon',
        emoji: '🎗️',
        price: 60,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      // Plant Skins
      ShopItem(
        id: 'skin_golden',
        name: 'Golden Rose',
        emoji: '🌼',
        price: 250,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'skin_crystal',
        name: 'Crystal Bloom',
        emoji: '💎',
        price: 400,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'skin_rainbow',
        name: 'Rainbow Flower',
        emoji: '🌈',
        price: 350,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'skin_cherry',
        name: 'Cherry Blossom',
        emoji: '🌸',
        price: 150,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
      // Adventure Keys
      ShopItem(
        id: 'key_cave',
        name: 'Cave Key',
        emoji: '🗝️',
        price: 500,
        category: 'adventure_key',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'key_sky',
        name: 'Sky Pass',
        emoji: '☁️',
        price: 600,
        category: 'adventure_key',
        owned: false,
        equipped: false,
      ),
      // 🎃 HALLOWEEN SPECIALS
      ShopItem(
        id: 'acc_pumpkin_hat',
        name: 'Pumpkin Hat',
        emoji: '🎃',
        price: 150,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_ghost_ears',
        name: 'Ghost Ears',
        emoji: '👻',
        price: 200,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_witch_hat',
        name: 'Witch Hat',
        emoji: '🧙‍♀️',
        price: 250,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_bat_wings',
        name: 'Bat Wings',
        emoji: '🦇',
        price: 350,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_spider_kitten',
        name: 'Spider Kitten',
        emoji: '🕷️',
        price: 180,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      // ❄️ WINTER SPECIALS
      ShopItem(
        id: 'acc_santa_hat',
        name: 'Santa Hat',
        emoji: '🎅',
        price: 200,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_earmuffs',
        name: 'Earmuffs',
        emoji: '🧣',
        price: 120,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_snowflakes',
        name: 'Snowflake Charm',
        emoji: '❄️',
        price: 180,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_reindeer_antlers',
        name: 'Reindeer Antlers',
        emoji: '🦌',
        price: 300,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      // MORE GARDEN SKINS
      ShopItem(
        id: 'skin_pumpkin',
        name: 'Pumpkin Patch',
        emoji: '🎃',
        price: 200,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'skin_winter',
        name: 'Frozen Garden',
        emoji: '❄️',
        price: 300,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
      // ADDITIONAL ADVENTURE KEYS
      ShopItem(
        id: 'key_forest',
        name: 'Forest Key',
        emoji: '🌲',
        price: 400,
        category: 'adventure_key',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'key_marsh',
        name: 'Marsh Key',
        emoji: '🌙',
        price: 700,
        category: 'adventure_key',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'key_cosmos',
        name: 'Cosmos Key',
        emoji: '🌌',
        price: 1000,
        category: 'adventure_key',
        owned: false,
        equipped: false,
      ),
      // 🎃 NEW HALLOWEEN SPECIALS
      ShopItem(
        id: 'acc_candy_basket',
        name: 'Candy Basket',
        emoji: '🍬',
        price: 100,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_vampire_cape',
        name: 'Vampire Cape',
        emoji: '🧛',
        price: 280,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_franken_bolts',
        name: 'Frankie Bolts',
        emoji: '🔩',
        price: 140,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      // ❄️ NEW WINTER SPECIALS
      ShopItem(
        id: 'acc_snowman_scarf',
        name: 'Snowman Scarf',
        emoji: '☃️',
        price: 130,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_elf_ears',
        name: 'Elf Hat & Ears',
        emoji: '🧝',
        price: 220,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'acc_ice_crown',
        name: 'Ice Crown',
        emoji: '❄️',
        price: 350,
        category: 'pet_accessory',
        owned: false,
        equipped: false,
      ),
      // NEW GARDEN SKINS
      ShopItem(
        id: 'skin_spooky',
        name: 'Spooky Mansion',
        emoji: '🪦',
        price: 250,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
      ShopItem(
        id: 'skin_gingerbread',
        name: 'Gingerbread House',
        emoji: '🏠',
        price: 280,
        category: 'plant_skin',
        owned: false,
        equipped: false,
      ),
    ];
    for (final item in items) {
      await into(shopItems).insertOnConflictUpdate(item);
    }
  }

  Future<void> _seedAdventureLands() async {
    final lands = [
      AdventureLand(
        id: 'land_meadow',
        name: 'Sunny Meadow',
        emoji: '🌻',
        description: 'A bright meadow where your journey begins.',
        requiredLevel: 1,
        unlocked: true,
        progress: 0,
      ),
      AdventureLand(
        id: 'land_forest',
        name: 'Whispering Forest',
        emoji: '🌲',
        description: 'Ancient trees hold secrets of the forest.',
        requiredLevel: 3,
        unlocked: false,
        progress: 0,
      ),
      AdventureLand(
        id: 'land_cave',
        name: 'Crystal Cave',
        emoji: '💎',
        description: 'Glittering crystals light this underground world.',
        requiredLevel: 5,
        unlocked: false,
        progress: 0,
      ),
      AdventureLand(
        id: 'land_marsh',
        name: 'Moonlit Marsh',
        emoji: '🌙',
        description: 'A mystical marshland that glows under the moon.',
        requiredLevel: 10,
        unlocked: false,
        progress: 0,
      ),
      AdventureLand(
        id: 'land_sky',
        name: 'Cloud Kingdom',
        emoji: '☁️',
        description: 'Floating islands high above the clouds.',
        requiredLevel: 15,
        unlocked: false,
        progress: 0,
      ),
      AdventureLand(
        id: 'land_cosmos',
        name: 'Star Cosmos',
        emoji: '🌟',
        description: 'The final frontier — a universe of blooms.',
        requiredLevel: 25,
        unlocked: false,
        progress: 0,
      ),
    ];
    for (final land in lands) {
      await into(adventureLands).insertOnConflictUpdate(land);
    }
  }
}

// ─────────────────────────────────────────────
// Connection
// ─────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bloomie.sqlite'));
    return NativeDatabase(file);
  });
}

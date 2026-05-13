import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tables
class Habits extends Table {
  TextColumn get id => text()();
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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSharedWithPartner => boolean().withDefault(const Constant(false))();
  IntColumn get iconBg => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitLogs extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();
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
  IntColumn get stage => integer()(); // Enum index
  RealColumn get growthPercent => real().withDefault(const Constant(0.0))();
  TextColumn get duoSessionId => text().references(DuoSessions, #id)();
  IntColumn get waterCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWateredAt => dateTime().nullable()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Habits, HabitLogs, DuoSessions, Plants])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Habit Queries
  Future<List<Habit>> getAllHabits() => (select(habits)..where((t) => t.isArchived.equals(false))).get();
  Future<int> insertHabit(Habit habit) => into(habits).insert(habit);
  Future updateHabit(Habit habit) => update(habits).replace(habit);
  Future archiveHabit(String id) => (update(habits)..where((t) => t.id.equals(id))).write(const HabitsCompanion(isArchived: Value(true)));

  // Log Queries
  Future<int> insertLog(HabitLog log) => into(habitLogs).insert(log);
  Future<List<HabitLog>> getLogsForHabit(String habitId) => (select(habitLogs)..where((t) => t.habitId.equals(habitId))).get();

  // Duo Queries
  Future<DuoSession?> getActiveSession() => (select(duoSessions)..where((t) => t.isActive.equals(true))).getSingleOrNull();
  Future<int> insertSession(DuoSession session) => into(duoSessions).insert(session);

  // Plant Queries
  Future<Plant?> getPlantForDuo(String duoSessionId) => (select(plants)..where((t) => t.duoSessionId.equals(duoSessionId) & t.stage.isSmallerThanValue(4))).getSingleOrNull();
  Future<int> insertPlant(Plant plant) => into(plants).insert(plant);
  Future updatePlant(Plant plant) => update(plants).replace(plant);
  Future<List<Plant>> getAllPlants() => select(plants).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bloomie.sqlite'));
    return NativeDatabase(file);
  });
}

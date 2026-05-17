import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Example Tables ────────────────────────────────────────────────────────

@DataClassName('UserData')
class UserTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();

  // ── Sync columns ──
  TextColumn get accountId => text().nullable()();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  TextColumn get lastWriterDeviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ───────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    UserTable,
    // Add more tables here
  ],
)
class AppDatabase extends _$AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Handle migrations here
      // Example:
      // if (from < 2) {
      //   await m.addColumn(userTable, userTable.newColumn);
      // }
    },
  );

  // ── User Table Methods ───────────────────────────────────────────────────

  Future<List<UserData>> getAllUsers() =>
      (select(userTable)..where((t) => t.deletedAt.isNull())).get();

  Stream<List<UserData>> watchAllUsers() =>
      (select(userTable)..where((t) => t.deletedAt.isNull())).watch();

  Future<UserData?> getUserById(String id) => (select(
    userTable,
  )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  Future insertUser(UserData user) =>
      into(userTable).insert(user, mode: InsertMode.insertOrReplace);

  Future softDeleteUser(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(userTable)..where((t) => t.id.equals(id))).write(
      UserTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
        lastWriterDeviceId: Value(await _getDeviceId()),
      ),
    );
  }

  Future<List<UserData>> getDirtyUsers() =>
      (select(userTable)..where((t) => t.dirty.equals(true))).get();

  Future<void> markUserClean(String id) =>
      (update(userTable)..where((t) => t.id.equals(id))).write(
        const UserTableCompanion(dirty: Value(false)),
      );

  // ── Sync Helpers ─────────────────────────────────────────────────────────

  Future<String> _getDeviceId() async {
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> backfillAccountId(String accountId) async {
    await batch((batch) {
      batch.update(
        userTable,
        UserTableCompanion(accountId: Value(accountId)),
        where: (t) => t.accountId.isNull(),
      );
    });
  }

  Future<void> clearAllUserData() async {
    await delete(userTable).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_skeleton.sqlite'));
    return NativeDatabase(file);
  });
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Import your remote datasources
// import 'package:bloomie/features/your_feature/data/datasources/your_remote_datasource.dart';

/// Central sync orchestration engine.
///
/// Implements delta-based sync with last-write-wins (updatedAt)
/// and deterministic tie-breaking (lastWriterDeviceId).
///
/// TODO: Implement for your specific data model
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  // final _db = AppDatabase.instance;
  // final _yourRemote = YourRemoteDataSource();

  static const _lastSyncKey = 'last_sync_timestamp';

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  final ValueNotifier<bool> syncing = ValueNotifier<bool>(false);

  Timer? _debounceTimer;

  /// Main entry point. Pulls remote changes then pushes local dirty rows.
  /// [immediate] skips the 3-second debounce.
  Future<void> sync({bool immediate = false}) async {
    syncing.value = true;
    if (immediate) {
      _debounceTimer?.cancel();
      await _performSync();
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 3), () => _performSync());
    }
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _isSyncing = true;
    debugPrint('[SyncService] Starting sync for user: $userId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPulledAt = prefs.getInt(_lastSyncKey) ?? 0;
      final syncStartTime = DateTime.now().millisecondsSinceEpoch;

      // 1. Push Local Dirty Rows FIRST
      await _push();

      // 2. Pull Remote Deltas
      await _pull(lastPulledAt);

      // 3. Update Sync Timestamp
      await prefs.setInt(_lastSyncKey, syncStartTime);

      debugPrint('[SyncService] Sync completed successfully at $syncStartTime');
    } catch (e, stack) {
      debugPrint('[SyncService] Sync failed: $e');
      debugPrint(stack.toString());
    } finally {
      _isSyncing = false;
      syncing.value = false;
    }
  }

  // ── Pull Logic ───────────────────────────────────────────────────────────

  Future<void> _pull(int since) async {
    // TODO: Implement pull logic for your data model
    // Example:
    // final deltas = await _yourRemote.fetchDelta(since);
    // for (final remote in deltas) {
    //   final local = await _db.getYourEntityById(remote.id);
    //   if (shouldUpdateLocal(local?.updatedAt, local?.lastWriterDeviceId,
    //       remote.updatedAt, remote.lastWriterDeviceId,
    //       localDirty: local?.dirty ?? false)) {
    //     await _db.insertYourEntity(remote);
    //   }
    // }
  }

  // ── Push Logic ───────────────────────────────────────────────────────────

  Future<void> _push() async {
    // TODO: Implement push logic for your data model
    // Example:
    // final dirtyRows = await _db.getDirtyYourEntities();
    // for (final row in dirtyRows) {
    //   await _yourRemote.push(row);
    //   await _db.markYourEntityClean(row.id);
    // }
  }

  /// Clear all sync metadata (timestamp) from SharedPreferences.
  /// Called on logout to ensure next user pulls a fresh delta.
  Future<void> clearSyncMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
    debugPrint('[SyncService] Sync metadata cleared.');
  }
}

/// Conflict resolution helper
bool shouldUpdateLocal(
  int? localUpdatedAt,
  String? localDeviceId,
  int remoteUpdatedAt,
  String? remoteDeviceId, {
  bool localDirty = false,
}) {
  // Local dirty rows always win (preserve user's intent)
  if (localDirty) return false;

  // Local was never written, accept remote
  if (localUpdatedAt == null) return true;

  // Remote is newer
  if (remoteUpdatedAt > localUpdatedAt) return true;

  // Same timestamp, deterministic tie-break by device ID
  if (remoteUpdatedAt == localUpdatedAt) {
    if (localDeviceId == null) return true;
    if (remoteDeviceId == null) return false;
    return remoteDeviceId.compareTo(localDeviceId) > 0;
  }

  return false;
}

part of 'sync_bloc.dart';

class SyncState extends Equatable {
  final bool isSyncing;
  final String? error;
  final DateTime? lastSynced;
  const SyncState({required this.isSyncing, this.error, this.lastSynced});
  const SyncState.idle({DateTime? lastSynced}) : this(isSyncing: false, lastSynced: lastSynced);
  const SyncState.syncing({DateTime? lastSynced}) : this(isSyncing: true, lastSynced: lastSynced);
  const SyncState.error(String message, {DateTime? lastSynced}) : this(isSyncing: false, error: message, lastSynced: lastSynced);

  @override
  List<Object?> get props => [isSyncing, error, lastSynced];
}

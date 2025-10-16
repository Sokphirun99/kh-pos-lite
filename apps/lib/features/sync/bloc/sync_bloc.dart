import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cashier_app/services/sync_service.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends HydratedBloc<SyncEvent, SyncState> {
  final SyncService sync;
  SyncBloc(this.sync) : super(const SyncState.idle()) {
    on<SyncTriggered>((event, emit) async {
      emit(SyncState.syncing(lastSynced: state.lastSynced));
      try {
        await sync.push();
        await sync.pull();
        emit(SyncState.idle(lastSynced: DateTime.now().toUtc()));
      } catch (e) {
        emit(SyncState.error(e.toString(), lastSynced: state.lastSynced));
      }
    });
  }

  @override
  SyncState? fromJson(Map<String, dynamic> json) {
    try {
      final ts = json['lastSynced'] as String?;
      final last = ts != null ? DateTime.parse(ts).toUtc() : null;
      return SyncState.idle(lastSynced: last);
    } catch (_) {
      return const SyncState.idle();
    }
  }

  @override
  Map<String, dynamic>? toJson(SyncState state) => {
    'lastSynced': state.lastSynced?.toIso8601String(),
  };
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/services/key_value_service.dart';

class FeatureFlagsState extends Equatable {
  final bool showSyncBanner;
  final bool enableBatchSync;
  final int batchSize; // 5-50
  const FeatureFlagsState({
    required this.showSyncBanner,
    required this.enableBatchSync,
    required this.batchSize,
  });

  FeatureFlagsState copyWith({
    bool? showSyncBanner,
    bool? enableBatchSync,
    int? batchSize,
  }) => FeatureFlagsState(
    showSyncBanner: showSyncBanner ?? this.showSyncBanner,
    enableBatchSync: enableBatchSync ?? this.enableBatchSync,
    batchSize: batchSize ?? this.batchSize,
  );

  @override
  List<Object?> get props => [showSyncBanner, enableBatchSync, batchSize];
}

class FeatureFlagsCubit extends Cubit<FeatureFlagsState> {
  static const _kShowSyncBanner = 'flag_showSyncBanner';
  static const _kEnableBatchSync = 'flag_enableBatchSync';
  static const _kSyncBatchSize = 'sync_batch_size';

  FeatureFlagsCubit()
    : super(
        FeatureFlagsState(
          showSyncBanner: KeyValueService.get<bool>(_kShowSyncBanner) ?? true,
          enableBatchSync: KeyValueService.get<bool>(_kEnableBatchSync) ?? true,
          batchSize: (KeyValueService.get<int>(_kSyncBatchSize) ?? 20).clamp(
            5,
            50,
          ),
        ),
      );

  Future<void> setShowSyncBanner(bool value) async {
    emit(state.copyWith(showSyncBanner: value));
    await KeyValueService.set(_kShowSyncBanner, value);
  }

  Future<void> setEnableBatchSync(bool value) async {
    emit(state.copyWith(enableBatchSync: value));
    await KeyValueService.set(_kEnableBatchSync, value);
  }

  Future<void> setBatchSize(int value) async {
    final v = value.clamp(5, 50);
    emit(state.copyWith(batchSize: v));
    await KeyValueService.set(_kSyncBatchSize, v);
  }
}

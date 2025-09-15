import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier_app/services/key_value_service.dart';

class FeatureFlagsState extends Equatable {
  final bool showSyncBanner;
  final bool enableBatchSync;
  const FeatureFlagsState({required this.showSyncBanner, required this.enableBatchSync});

  FeatureFlagsState copyWith({bool? showSyncBanner, bool? enableBatchSync}) => FeatureFlagsState(
        showSyncBanner: showSyncBanner ?? this.showSyncBanner,
        enableBatchSync: enableBatchSync ?? this.enableBatchSync,
      );

  @override
  List<Object?> get props => [showSyncBanner, enableBatchSync];
}

class FeatureFlagsCubit extends Cubit<FeatureFlagsState> {
  static const _kShowSyncBanner = 'flag_showSyncBanner';
  static const _kEnableBatchSync = 'flag_enableBatchSync';

  FeatureFlagsCubit()
      : super(FeatureFlagsState(
          showSyncBanner: KeyValueService.get<bool>(_kShowSyncBanner) ?? true,
          enableBatchSync: KeyValueService.get<bool>(_kEnableBatchSync) ?? true,
        ));

  Future<void> setShowSyncBanner(bool value) async {
    emit(state.copyWith(showSyncBanner: value));
    await KeyValueService.set(_kShowSyncBanner, value);
  }

  Future<void> setEnableBatchSync(bool value) async {
    emit(state.copyWith(enableBatchSync: value));
    await KeyValueService.set(_kEnableBatchSync, value);
  }
}

import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<bool> {
  ThemeCubit() : super(false);

  void setDark(bool isDark) => emit(isDark);

  @override
  bool? fromJson(Map<String, dynamic> json) => json['dark'] as bool?;

  @override
  Map<String, dynamic>? toJson(bool state) => {'dark': state};
}


import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class LocaleCubit extends HydratedCubit<Locale?> {
  LocaleCubit() : super(null);

  void setLocale(Locale? locale) => emit(locale);

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String?;
    return code == null ? null : Locale(code);
  }

  @override
  Map<String, dynamic>? toJson(Locale? state) => {'code': state?.languageCode};
}

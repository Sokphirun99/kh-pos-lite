import 'package:hydrated_bloc/hydrated_bloc.dart';

class ReportsCubit extends HydratedCubit<String> {
  ReportsCubit() : super('No data');

  void setSummary(String v) => emit(v);

  @override
  String? fromJson(Map<String, dynamic> json) => json['summary'] as String?;

  @override
  Map<String, dynamic>? toJson(String state) => {'summary': state};
}

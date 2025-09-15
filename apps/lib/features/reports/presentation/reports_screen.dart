import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reports_cubit.dart';
import 'package:cashier_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cashier_app/features/settings/bloc/feature_flags_cubit.dart';
import 'package:cashier_app/features/common/widgets/sync_banner.dart';
import 'package:cashier_app/features/sync/bloc/sync_bloc.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: const [
          SyncBanner(),
          Expanded(child: _ReportsSummary()),
        ],
      ),
    );
  }
}

class _ReportsSummary extends StatelessWidget {
  const _ReportsSummary();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<ReportsCubit, String>(
        builder: (context, summary) => Text('Summary: $summary'),
      ),
    );
  }
}

import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/blocs/expense_summary/expense_summary_bloc.dart';
import 'package:uangin/blocs/get_budgets/get_budgets_bloc.dart';
import 'package:uangin/features/expense_summary/widgets/expense_summary_chart.dart';

class ExpenseSummaryScreen extends StatelessWidget {
  final String userId;
  const ExpenseSummaryScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetBudgetsBloc, GetBudgetsState>(
      builder: (context, budgetState) {
        final budgets = budgetState is GetBudgetsSuccess
            ? budgetState.budgetList
            : <Budgets>[];

        return BlocBuilder<ExpenseSummaryBloc, ExpenseSummaryState>(
          builder: (context, summaryState) {
            if (summaryState is ExpenseSummaryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (summaryState is ExpenseSummarySuccess) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    ExpenseSummaryChart(
                        breakdown: summaryState.breakdown,
                        totalSpent: summaryState.totalSpent,
                        budgets: budgets)
                  ],
                ),
              );
            }

            if (summaryState is ExpenseSummaryFailure) {
              return Center(
                child: Text('Error loading expense summary'),
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}

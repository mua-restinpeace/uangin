import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/blocs/expense_summary/expense_summary_bloc.dart';
import 'package:uangin/blocs/get_budgets/get_budgets_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/expense_summary/widgets/expense_summary_chart.dart';

class ExpenseSummaryScreen extends StatelessWidget {
  final String userId;
  final double totalAllocated;
  const ExpenseSummaryScreen(
      {required this.userId, required this.totalAllocated, super.key});

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
                child: Column(
                  children: [
                    ExpenseSummaryChart(
                        breakdown: summaryState.breakdown,
                        totalSpent: summaryState.totalSpent,
                        totalAllocated: totalAllocated,
                        budgets: budgets),
                    const SizedBox(
                      height: 24,
                    ),
                    _buildBreakdown(
                        context: context,
                        breakdown: summaryState.breakdown,
                        budgets: budgets)
                  ],
                ),
              );
            }

            if (summaryState is ExpenseSummaryFailure) {
              return const Center(
                child: Text('Error loading expense summary'),
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildBreakdown(
      {required BuildContext context,
      required List<Budgets> budgets,
      required Map<String, double> breakdown}) {
    return Container(
      decoration: BoxDecoration(
          color: MyColors.fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MyColors.lightGrey)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Breakdown',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 16),
          ),
          const SizedBox(
            height: 12,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: budgets.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: 12,
            ),
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final color =
                  Color(int.parse('0xFF${budget.color.replaceAll('#', '')}'));
              final spentAmount = breakdown[budget.name] ?? 0.0;
              final percentage = (spentAmount / totalAllocated * 100);

              return _buildBreakdownItem(
                  context, percentage, budget.name, spentAmount, color);
            },
          )
        ]),
      ),
    );
  }

  Widget _buildBreakdownItem(BuildContext context, double percentage,
      String budgetName, double spentAmount, Color color) {
    return Row(
      children: [
        Container(
          width: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 14, color: MyColors.white),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          budgetName,
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 16),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('IDR',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 16, color: MyColors.grey)),
            const SizedBox(
              width: 4,
            ),
            Text(
              MoneyFormatter(amount: spentAmount).output.withoutFractionDigits,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 16),
            )
          ],
        )
      ],
    );
  }
}

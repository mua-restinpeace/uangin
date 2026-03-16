import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/blocs/expense_summary/expense_summary_bloc.dart';
import 'package:uangin/blocs/get_budgets/get_budgets_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/custom_linear_progress_bar.dart';
import 'package:uangin/features/add_budgets/views/add_budgets_screen.dart';
import 'package:uangin/features/expense_summary/widgets/budgets/budget_chart.dart';

class BudgetsTab extends StatelessWidget {
  final String userId;
  const BudgetsTab({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetBudgetsBloc, GetBudgetsState>(
      builder: (context, budgetsState) {
        if (budgetsState is GetBudgetsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (budgetsState is GetBudgetsSuccess) {
          final totalAllocated = budgetsState.budgetList.fold(
              0.0,
              (previousValue, element) =>
                  previousValue += element.allocatedAmount);
          return BlocBuilder<ExpenseSummaryBloc, ExpenseSummaryState>(
            builder: (context, summaryState) {
              if (summaryState is ExpenseSummaryLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (summaryState is ExpenseSummarySuccess) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildAddNewBudgetButton(context),
                        const SizedBox(
                          height: 48,
                        ),
                        BudgetChart(
                            totalAllocated: totalAllocated,
                            spentAmount: summaryState.totalSpent),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.95),
                          itemCount: budgetsState.budgetList.length,
                          itemBuilder: (context, index) {
                            final budget = budgetsState.budgetList[index];
                            return _buildBudgetCard(context, budget);
                          },
                        ),
                        const SizedBox(
                          height: 48,
                        )
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddNewBudgetButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBudgetsScreen(userId: userId,),
            ));
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
            color: MyColors.fillColor,
            border: Border.all(color: MyColors.lightGrey),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/icons/plus.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                  MyColors.onPrimary.withOpacity(0.8), BlendMode.srcIn),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              'New',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Budgets budget) {
    final color = Color(int.parse('0xFF${budget.color.replaceAll('#', '')}'));
    final percentageLeft = budget.allocatedAmount > 0
        ? (budget.spentAmount / budget.allocatedAmount * 100)
        : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: MyColors.fillColor,
          border: Border.all(color: MyColors.lightGrey),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16)),
                child: SvgPicture.asset(
                  budget.icon,
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  budget.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 16),
                ),
              )
            ],
          ),
          const Spacer(),
          Text(
            '${percentageLeft.toStringAsFixed(0)}% used',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 14,
                color: budget.spentAmount > budget.allocatedAmount
                    ? MyColors.red
                    : MyColors.green),
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Text('IDR',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 28, color: MyColors.grey)),
              const SizedBox(
                width: 4,
              ),
              Text(
                MoneyFormatter(
                        amount: (budget.allocatedAmount - budget.spentAmount))
                    .output
                    .withoutFractionDigits,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    color: budget.spentAmount > budget.allocatedAmount
                        ? MyColors.red
                        : MyColors.black),
              )
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            'left this week',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 14, color: MyColors.lightGrey),
          ),
          const Spacer(),
          CustomLinearProgressBar(
              percentage: percentageLeft / 100, progressColor: color)
        ],
      ),
    );
  }
}

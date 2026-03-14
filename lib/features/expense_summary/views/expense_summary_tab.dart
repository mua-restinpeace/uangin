import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/blocs/expense_summary/expense_summary_bloc.dart';
import 'package:uangin/blocs/get_budgets/get_budgets_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/expense_summary/widgets/expense_summary_chart.dart';

class ExpenseSummaryScreen extends StatefulWidget {
  final String userId;
  final double totalAllocated;
  const ExpenseSummaryScreen(
      {required this.userId, required this.totalAllocated, super.key});

  @override
  State<ExpenseSummaryScreen> createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  SummaryFilter _selectedFilter = SummaryFilter.thisWeek;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  void _loadTransaction() {
    context
        .read<ExpenseSummaryBloc>()
        .add(GetExpenseSummary(widget.userId, _selectedFilter));
  }

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
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDropDownButton(context),
                      ExpenseSummaryChart(
                          breakdown: summaryState.breakdown,
                          totalSpent: summaryState.totalSpent,
                          totalAllocated: getTotalAllocatedWithFilter(_selectedFilter),
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

  Widget _buildDropDownButton(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: MyColors.fillColor,
        border: Border.all(color: MyColors.lightGrey,),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<SummaryFilter>(
            value: _selectedFilter,
            icon: SvgPicture.asset(
              'lib/assets/icons/cevron-down.svg',
              width: 24,
              height: 24,
            ),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14),
            borderRadius: BorderRadius.circular(16),
            dropdownColor: MyColors.fillColor,
            onChanged: (SummaryFilter? newFilter) {
              if(newFilter != null){
                setState(() {
                  _selectedFilter = newFilter;
                });
              }
              _loadTransaction();
            },
            items: const [
              DropdownMenuItem(
                value: SummaryFilter.thisWeek,
                child: Text('This Week'),
              ),
              DropdownMenuItem(
                value: SummaryFilter.lastWeek,
                child: Text('Last Week'),
              ),
              DropdownMenuItem(
                value: SummaryFilter.thisMonth,
                child: Text('This Month'),
              ),
              DropdownMenuItem(
                value: SummaryFilter.lastMonth,
                child: Text('Last Month'),
              ),
              DropdownMenuItem(
                value: SummaryFilter.thisYear,
                child: Text('This Year'),
              ),
            ],
          ),
        ),
      ),
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
              final percentage = (spentAmount / getTotalAllocatedWithFilter(_selectedFilter) * 100);

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

  double getTotalAllocatedWithFilter(SummaryFilter filter) {
    switch (filter) {
      case SummaryFilter.thisWeek:
        return widget.totalAllocated;
      case SummaryFilter.lastWeek:
        return widget.totalAllocated;
      case SummaryFilter.thisMonth:
        return widget.totalAllocated * 4;
      case SummaryFilter.lastMonth:
        return widget.totalAllocated * 4;
      case SummaryFilter.thisYear:
        return widget.totalAllocated * 48;
      default:
        log('getTotalAllocatedWithFilter return default');
        return widget.totalAllocated;
    }
  }
}

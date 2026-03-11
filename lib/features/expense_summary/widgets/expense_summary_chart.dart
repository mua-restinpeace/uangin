import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/expense_summary/widgets/custom_chart.dart';

class ExpenseSummaryChart extends StatelessWidget {
  final Map<String, double> breakdown;
  final double totalSpent;
  final List<Budgets> budgets;

  const ExpenseSummaryChart(
      {required this.breakdown,
      required this.totalSpent,
      required this.budgets,
      super.key});

  @override
  Widget build(BuildContext context) {
    final colorMap = <String, Color>{};

    for (var budget in budgets) {
      final color = Color(int.parse('0xFF${budget.color.replaceAll('#', '')}'));
      colorMap[budget.name] = color;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                Center(
                  child: CustomChart(
                      data: breakdown,
                      colors: colorMap,
                      strokeWidth: 40,
                      totalAllocated: 350000,
                      size: MediaQuery.of(context).size.width * 0.6),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total Expense',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('IDR',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 32, color: MyColors.grey)),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            MoneyFormatter(amount: totalSpent)
                                .output
                                .withoutFractionDigits,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 32),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

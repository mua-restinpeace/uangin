import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/expense_summary/widgets/budgets/half_donut_chart.dart';

class BudgetChart extends StatelessWidget {
  final double totalAllocated;
  final double spentAmount;
  const BudgetChart(
      {required this.totalAllocated, required this.spentAmount, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            height: 125,
            child: Stack(
              children: [
                Center(
                  child: HalfDonutChart(
                      size: MediaQuery.of(context).size.width * 0.7,
                      totalAllocated: totalAllocated,
                      strokeWidth: 48,
                      spentAmount: spentAmount),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('IDR',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                      fontSize: 32, color: MyColors.grey)),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            MoneyFormatter(amount: spentAmount)
                                .output
                                .withoutFractionDigits,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 32),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'budgets left',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 12),
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

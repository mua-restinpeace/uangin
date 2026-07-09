import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/custom_linear_progress_bar.dart';
import 'package:uangin/core/widgets/my_button.dart';
import 'package:uangin/features/allocate_savings/views/allocate_saving_screen.dart';

class SavingGoalGrid extends StatelessWidget {
  final String userId;
  final List<SavingGoals> goals;
  const SavingGoalGrid({required this.userId, required this.goals, super.key});

  double _percentageProgress(double current, double target) {
    if (target <= 0) return 0.0;

    return (current / target).clamp(0.0, 1.0);
  }

  int _progressPercentageText(double current, double target) {
    return (_percentageProgress(current, target) * 100).round();
  }

  String _formattedMoney(double amount) {
    final formatted = MoneyFormatter(amount: amount);
    return formatted.output.nonSymbol;
  }

  static const List<Color> _progressColor = [
    MyColors.orange,
    MyColors.purple,
    MyColors.deepBlue,
    MyColors.yellow,
    MyColors.green,
    MyColors.red
  ];

  Color _goalColor(int index) {
    return _progressColor[index % _progressColor.length];
  }

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              SvgPicture.asset(
                'lib/assets/icons/empty-list.svg',
                height: 64,
                width: 64,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'No saving goals yet',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 18, color: MyColors.grey),
              )
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final progressColor = _goalColor(index);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: MyColors.fillColor,
              border: Border.all(color: MyColors.lightGrey),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toBeginningOfSentenceCase(goal.name),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 16),
                    ),
                    MyButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllocateSavingScreen(
                                  userId: userId, goal: goal),
                            ),
                          );
                        },
                        content: SvgPicture.asset(
                          'lib/assets/icons/plus.svg',
                          width: 20,
                          height: 20,
                        ))
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'IDR',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: MyColors.grey, fontSize: 36),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        _formattedMoney(goal.targetAmount),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 36, color: MyColors.onPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'IDR ${_formattedMoney(goal.targetAmount - goal.currentAmount)} left',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 14, color: MyColors.grey),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomLinearProgressBar(
                        percentage: _percentageProgress(
                          goal.currentAmount,
                          goal.targetAmount,
                        ),
                        progressColor: progressColor,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${_progressPercentageText(goal.currentAmount, goal.targetAmount)}%',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 14, color: MyColors.grey),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';

class TotalSavedCard extends StatelessWidget {
  final double totalSaved;
  const TotalSavedCard({required this.totalSaved, super.key});

  String _formattedMoney(double amount) {
    final formatter = MoneyFormatter(amount: amount);
    return formatter.output.nonSymbol;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: MyColors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -5,
            bottom: -5,
            child: Opacity(
              opacity: 0.5,
              child: SvgPicture.asset(
                'lib/assets/images/pig-ballance.svg',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Saved',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 14),
                ),
                const SizedBox(
                  height: 8,
                ),
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
                        _formattedMoney(totalSaved),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 36, color: MyColors.white),
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

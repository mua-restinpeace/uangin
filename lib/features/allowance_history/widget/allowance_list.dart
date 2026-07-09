import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';

class AllowanceList extends StatelessWidget {
  final BuildContext context;
  final List<Allowances> allowances;
  final String? dateFormat;
  const AllowanceList(
      {required this.context,
      required this.allowances,
      this.dateFormat,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: allowances.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const Divider(
        color: MyColors.lightGrey,
        thickness: 1,
        height: 24,
      ),
      itemBuilder: (context, index) {
        final allowance = allowances[index];

        final color = allowance.type == AllowanceType.topUp
            ? MyColors.primary
            : MyColors.lightGrey;
        final icon = allowance.type == AllowanceType.topUp
            ? 'lib/assets/icons/coin.svg'
            : 'lib/assets/icons/coin-swap.svg';
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allowance.type == AllowanceType.topUp
                        ? 'Allowance'
                        : 'Allowance ${allowance.type.name}',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 16),
                  ),
                  Text(
                    allowance.date != null
                        ? DateFormat(dateFormat ?? 'EEE, dd MMMM yyyy')
                            .format(allowance.date!)
                        : 'N/A',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14),
                  )
                ],
              ),
            ),
            Text(
              'IDR ${MoneyFormatter(amount: allowance.amount).output.nonSymbol}',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 16),
            ),
            const SizedBox(
              width: 12,
            ),
          ],
        );
      },
    );
  }
}

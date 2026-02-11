import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/custome_linear_progress_bar.dart';
import 'package:uangin/core/widgets/my_button.dart';
import 'package:uangin/features/home/blocs/get_current_allowance/get_current_allowance_bloc.dart';
import 'package:user_repository/user_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetCurrentAllowanceBloc(context.read<UserRepository>())..add(GetCurrentAllowance()),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(
                  height: 16,
                ),
                BlocBuilder<GetCurrentAllowanceBloc, GetCurrentAllowanceState>(
                  builder: (context, state) {
                    if (state is GetCurrentAllowanceLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is GetCurrentAllowanceSuccess) {
                      MoneyFormatter allowance = MoneyFormatter(amount: state.currentAllowance);
                      return _buildAllowanceCard(context, allowance.output.nonSymbol);
                    }
                    return _buildAllowanceCard(context, (0.0).toString());
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Spending',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 20),
                ),
                const SizedBox(
                  height: 8,
                ),
                _buildSpendingSection(context),
                const SizedBox(
                  height: 16,
                ),
                _buildTrancsactionSection(context),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'lib/assets/icons/profile.svg',
          width: 40,
          height: 40,
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          'Hi, Jeda',
          style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
        const Spacer(),
        SvgPicture.asset(
          'lib/assets/icons/bell.svg',
          width: 32,
          height: 32,
        )
      ],
    );
  }

  Widget _buildAllowanceCard(BuildContext context, String currentAllowance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Allowance',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16),
              ),
              Text(
                '12th January 2026',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text(
                'IDR',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: MyColors.grey, fontSize: 32),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                currentAllowance.toString(),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 32),
              )
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyButton(
                onTap: () {},
                content: Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/icons/plus.svg',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Add allowance',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 16, color: MyColors.white),
                    )
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              MyButton(
                onTap: () {},
                content: SvgPicture.asset(
                  'lib/assets/icons/eye_open_white.svg',
                  width: 24,
                  height: 24,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSpendingSection(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: MyColors.fillColor,
                  border: Border.all(color: MyColors.lightGrey),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'lib/assets/icons/chart.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Expense Summary',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 16),
                      )
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'IDR',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: MyColors.grey, fontSize: 16),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '350.000',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 16),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Text(
                        '-IDR 120.000',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                                fontSize: 12, color: const Color(0xff0ACE89)),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '(40% left)',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 12, color: MyColors.red),
                      )
                    ],
                  ),
                  const Spacer(),
                  const CustomeLinearProgressBar(
                    percentage: 0.6,
                    progressColor: MyColors.orange,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: MyColors.fillColor,
                  border: Border.all(color: MyColors.lightGrey),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'lib/assets/icons/lend_money.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Saving Goals',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 16),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Set your goals and track your progrres',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  MyButton(
                      onTap: () {},
                      content: Text(
                        'Add Goals',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 14, color: MyColors.white),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrancsactionSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: MyColors.fillColor,
          border: Border.all(color: MyColors.lightGrey),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transaction',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 16, color: const Color(0xff8DAC4A)),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: 6,
              separatorBuilder: (context, index) => const Divider(
                color: MyColors.lightGrey,
                thickness: 1,
                height: 24,
              ),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/icons/knife_fork.svg',
                      height: 44,
                      width: 44,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Food & Drinks',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 16),
                          ),
                          Text(
                            '8th January 2026',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                    Text(
                      'IDR 12.000',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 16),
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

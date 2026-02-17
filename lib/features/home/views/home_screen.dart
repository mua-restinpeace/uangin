import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/blocs/delete_transaction/delete_transaction_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/custome_linear_progress_bar.dart';
import 'package:uangin/core/widgets/my_button.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/core/widgets/transaction_item/transaction_item.dart';
import 'package:uangin/features/home/blocs/get_recent_transactions/get_recent_transactions_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String date = DateFormat('EEE, dd MMMM yyyy').format(DateTime.now());
  bool _showCurrentAllowance = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userState = context.read<GetUserBloc>().state;
    if (userState is GetUserSuccess) {
      final userId = userState.user.userId;

      context
          .read<GetRecentTransactionsBloc>()
          .add(GetRecentTransactions(userId));
    }
  }

  void toggleShowCurrentAllowance() {
    setState(() {
      _showCurrentAllowance = !_showCurrentAllowance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<GetUserBloc, GetUserState>(
          listener: (context, state) {
            if (state is GetUserSuccess) {
              _loadData();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<GetUserBloc, GetUserState>(
                    builder: (context, state) {
                      if (state is GetUserLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetUserSuccess) {
                        return _buildHeader(context, state.user.name);
                      }

                      return _buildHeader(context, '');
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  BlocBuilder<GetUserBloc, GetUserState>(
                    builder: (context, state) {
                      if (state is GetUserLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is GetUserSuccess) {
                        log('HomeScreen: Rebuilding with user information - ${state.user}');
                        return _buildAllowanceCard(
                            context, state.user.currentAllowance, date);
                      }
                      return _buildAllowanceCard(context, 0.0, date);
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
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
          'Hi, $name',
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

  Widget _buildAllowanceCard(
      BuildContext context, double currentAllowance, String date) {
    MoneyFormatter allowanceRemaining =
        MoneyFormatter(amount: currentAllowance);
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
                date,
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
              _showCurrentAllowance
                  ? Text(
                      allowanceRemaining.output.nonSymbol.toString(),
                      style: currentAllowance > 0
                          ? Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 32)
                          : Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 32, color: MyColors.red),
                    )
                  : Text(
                      allowanceRemaining.output.nonSymbol
                          .toString()
                          .replaceAll('-', '')
                          .replaceAll(RegExp(r"[^,.]"), "•"),
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
                onTap: toggleShowCurrentAllowance,
                content: _showCurrentAllowance
                    ? SvgPicture.asset(
                        'lib/assets/icons/eye_open_white.svg',
                        width: 24,
                        height: 24,
                      )
                    : SvgPicture.asset(
                        'lib/assets/icons/eye_close_white.svg',
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
              BlocBuilder<GetRecentTransactionsBloc, GetRecentTransactionsState>(
                  builder: (context, state) {
                if (state is GetRecentTransactionsFailure) {
                  return Center(
                    child: Text(
                      'Error loading recent transactions.',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 18),
                    ),
                  );
                } else if (state is GetRecentTransactionsSuccess) {
                  return _buildTransactionList(context, state.transactionList);
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, List<Transactions> transactions) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: transactions.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const Divider(
        color: MyColors.lightGrey,
        thickness: 1,
        height: 24,
      ),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionItem(
          transactions: transaction,
          budgetList: [],
          onDelete: () {
            context.read<DeleteTransactionBloc>().add(DeleteTransaction(
                transaction.userId, transaction.transactionId));
          },
          onEdited: (updatedTransaction) {},
        );
      },
    );
  }
}

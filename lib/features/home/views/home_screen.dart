import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/blocs/delete_transaction/delete_transaction_bloc.dart';
import 'package:uangin/blocs/expense_summary/expense_summary_bloc.dart';
import 'package:uangin/blocs/get_budgets/get_budgets_bloc.dart';
import 'package:uangin/blocs/get_total_allocated_budgets/get_total_allocated_budgets_bloc.dart';
import 'package:uangin/blocs/update_transaction/update_transaction_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/custom_linear_progress_bar.dart';
import 'package:uangin/core/widgets/my_button.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/core/widgets/profile_avatar.dart';
import 'package:uangin/core/widgets/transaction/transaction_item.dart';
import 'package:uangin/features/add_allowance/views/add_allowance_screen.dart';
import 'package:uangin/features/add_saving_goals/views/add_saving_goals_screen.dart';
import 'package:uangin/features/expense_summary/views/spending_analysis_screen.dart';
import 'package:uangin/features/home/blocs/get_active_saving_goals/get_active_saving_goals_bloc.dart';
import 'package:uangin/features/home/blocs/get_recent_transactions/get_recent_transactions_bloc.dart';
import 'package:uangin/features/transaction_records/views/transaction_records_screen.dart';
import 'package:uangin/features/wallet/views/wallet_screen.dart';
import 'package:user_repository/user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String date = DateFormat('EEE, dd MMMM yyyy').format(DateTime.now());
  bool _showCurrentAllowance = false;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userState = context.read<GetUserBloc>().state;
    if (userState is GetUserSuccess) {
      setState(() {
        _userId = userState.user.userId;
      });

      context.read<GetBudgetsBloc>().add(GetBudgets(_userId));

      context
          .read<GetRecentTransactionsBloc>()
          .add(GetRecentTransactions(_userId));

      context
          .read<ExpenseSummaryBloc>()
          .add(GetExpenseSummary(_userId, SummaryFilter.thisWeek));

      context
          .read<GetTotalAllocatedBudgetsBloc>()
          .add(GetTotalAllocatedBudgets(_userId));

      context.read<GetActiveSavingGoalsBloc>().add(GetActiveGoals(_userId));
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
                        return _buildHeader(state.user, context);
                      }

                      return const SizedBox.shrink();
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
                        // log('HomeScreen: Rebuilding with user information - ${state.user}');
                        return _buildAllowanceCard(
                            context,
                            state.user.currentAllowance,
                            state.user.totalSaving,
                            date);
                      }
                      return _buildAllowanceCard(context, 0.0, 0.0, date);
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
                  _buildTransactionSection(context),
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

  Widget _buildHeader(MyUser user, BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          user: user,
          radius: 24,
          fontSize: 16,
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          'Hi, ${user.name}',
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

  Widget _buildAllowanceCard(BuildContext context, double currentAllowance,
      double totalSaving, String date) {
    MoneyFormatter allowanceRemaining =
        MoneyFormatter(amount: currentAllowance);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WalletScreen(),
          ),
        );
      },
      child: Container(
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
                        style: currentAllowance >= 0
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAllowanceScreen(
                          currentAllowance: currentAllowance,
                          userId: _userId,
                        ),
                      ),
                    );
                  },
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
      ),
    );
  }

  Widget _buildSpendingSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildExpenseSummary(context),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Expanded(child: _buildSavingGoalsList([])),
                  const SizedBox(
                    height: 16,
                  ),
                  MyButton(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddSavingGoalsScreen(
                                userId: _userId,
                              ),
                            ));
                      },
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

  Widget _buildSavingGoalsList(List<SavingGoals> goals) {
    return BlocBuilder<GetActiveSavingGoalsBloc, GetActiveSavingGoalsState>(
      builder: (context, state) {
        if (state is GetActiveSavingGoalsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is GetActiveSavingGoalsSuccess) {
          final goals = state.goals;
          log('Saving goals list: ${state.goals}');
          if (goals.isEmpty) {
            return Text(
              'Set your goals and track your progress',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            );
          } else {
            return ListView.separated(
              // shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: 8,
              ),
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progressColor = _goalColor(index);
                final percentage =
                    (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                return Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          goal.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 12),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'IDR',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                            Text(
                              '${goal.targetAmount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontSize: 12),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomLinearProgressBar(
                            percentage: percentage,
                            progressColor: progressColor,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          '${(percentage * 100).round().toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12),
                        )
                      ],
                    )
                  ],
                );
              },
            );
          }
        }

        if (state is GetActiveSavingGoalsFailure) {
          return const Center(
            child: Text('Failed to fetch saving goals budget'),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildExpenseSummary(BuildContext context) {
    return BlocBuilder<ExpenseSummaryBloc, ExpenseSummaryState>(
      builder: (context, summaryState) {
        if (summaryState is ExpenseSummaryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (summaryState is ExpenseSummarySuccess) {
          return BlocBuilder<GetTotalAllocatedBudgetsBloc,
              GetTotalAllocatedBudgetsState>(
            builder: (context, allocatedState) {
              if (allocatedState is GetTotalAllocatedBudgetsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (allocatedState is GetTotalAllocatedBudgetsSuccess) {
                var totalAllocated = allocatedState.totalAllocated;
                final totalSpent = summaryState.totalSpent;
                final double percentage =
                    totalAllocated > 0 ? totalSpent / totalAllocated : 0;
                final spentPercentage = (100.00 - percentage * 100);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpendingAnalysisScreen(),
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: MyColors.fillColor,
                        border: Border.all(color: MyColors.lightGrey),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Spending Analysis',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 16),
                            )
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Total spent this week:',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Text(
                              'IDR',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                      color: MyColors.grey, fontSize: 16),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              MoneyFormatter(amount: totalSpent)
                                  .output
                                  .nonSymbol,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 16),
                            )
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '(${spentPercentage.toStringAsFixed(0)}% left)',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  fontSize: 14,
                                  color: spentPercentage < 50.0
                                      ? MyColors.red
                                      : MyColors.green),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomLinearProgressBar(
                          percentage: percentage,
                          progressColor: MyColors.orange,
                        )
                      ],
                    ),
                  ),
                );
              }

              if (allocatedState is GetTotalAllocatedBudgetsFailure) {
                return const Center(
                  child: Text('Failed to fetch total allocated budgets.'),
                );
              }

              return const SizedBox();
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTransactionSection(BuildContext context) {
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
                    onPressed: () {
                      final userState = context.read<GetUserBloc>().state;
                      if (userState is GetUserSuccess) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionRecordsScreen(
                                  userId: userState.user.userId),
                            ));
                      }
                    },
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
              BlocBuilder<GetBudgetsBloc, GetBudgetsState>(
                builder: (context, state) {
                  if (state is GetBudgetsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GetBudgetsSuccess) {
                    final budgetList = state.budgetList;

                    return BlocBuilder<GetRecentTransactionsBloc,
                        GetRecentTransactionsState>(builder: (context, state) {
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
                        return _buildTransactionList(
                            context, state.transactionList, budgetList);
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    });
                  }

                  if (state is GetBudgetsFailure) {
                    log("get budget failed: ${state.errorMsg}");
                    return const Center(
                      child: Text("Failed to fectch budgets"),
                    );
                  }

                  log("get budget return null");
                  return const SizedBox(
                    height: 56,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context,
      List<Transactions> transactions, List<Budgets> budgets) {
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
          budgetList: budgets,
          onDelete: () {
            context.read<DeleteTransactionBloc>().add(DeleteTransaction(
                transaction.userId, transaction.transactionId));
          },
          onEdited: (updatedTransaction) {
            log('updating transaction: $updatedTransaction');
            context.read<UpdateTransactionBloc>().add(UpdateTransaction(
                updatedTransaction, transaction.amount, transaction.budgetId));
          },
        );
      },
    );
  }
}

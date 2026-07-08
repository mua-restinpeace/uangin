import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/features/add_allowance/views/add_allowance_screen.dart';
import 'package:uangin/features/allowance_history/views/allowance_history_screen.dart';
import 'package:uangin/features/edit_allowance/views/edit_allowance_screen.dart';
import 'package:uangin/features/home/blocs/get_active_saving_goals/get_active_saving_goals_bloc.dart';
import 'package:uangin/features/wallet/widgets/saving_goal_grid.dart';
import 'package:uangin/features/wallet/widgets/total_saved_card.dart';
import 'package:uangin/features/wallet/widgets/wallet_ballance_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _showCurrentAllowance = false;

  void toggleShowCurrentAllowance() {
    setState(() {
      _showCurrentAllowance = !_showCurrentAllowance;
    });
  }

  void goToAddAllowance() {
    final state = context.read<GetUserBloc>().state;
    if (state is GetUserSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAllowanceScreen(
              userId: state.user.userId,
              currentAllowance: state.user.currentAllowance),
        ),
      );
    }
  }

  void openEditCurrentAllowance() {
    final state = context.read<GetUserBloc>().state;
    if (state is GetUserSuccess) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EditAllowanceScreen(userId: state.user.userId),
          ));
    }
  }

  void openAllowanceHistory() {
    final state = context.read<GetUserBloc>().state;
    if (state is GetUserSuccess) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AllowanceHistoryScreen(userId: state.user.userId),
          ));
    }
  }

  void handleWalletMenuAction(WalletMenuAction action) {
    switch (action) {
      case WalletMenuAction.editCurrentAllowance:
        openEditCurrentAllowance();
        break;

      case WalletMenuAction.allowanceHistory:
        openAllowanceHistory();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: canPop
            ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset(
                    'lib/assets/icons/arrow_left.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
              )
            : null,
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Wallet',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 20),
          ),
        ),
      ),
      body: BlocBuilder<GetUserBloc, GetUserState>(
        builder: (context, userState) {
          if (userState is! GetUserSuccess) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WalletBallanceCard(
                  currentAllowance: userState.user.currentAllowance,
                  showCurrentAllowance: _showCurrentAllowance,
                  onToggleVisibility: toggleShowCurrentAllowance,
                  onAddAllowance: goToAddAllowance,
                  onMenuSelected: handleWalletMenuAction,
                ),
                const SizedBox(
                  height: 20,
                ),
                TotalSavedCard(
                  totalSaved: userState.user.totalSaving,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Saving Goals',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 20),
                ),
                const SizedBox(
                  height: 8,
                ),
                BlocBuilder<GetActiveSavingGoalsBloc,
                    GetActiveSavingGoalsState>(
                  builder: (context, goalState) {
                    if (goalState is GetActiveSavingGoalsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (goalState is GetActiveSavingGoalsSuccess) {
                      final List<SavingGoals> goals = goalState.goals;
                      return SavingGoalGrid(
                          userId: userState.user.userId, goals: goals);
                    }

                    return Center(
                      child: SvgPicture.asset(
                        'lib/assets/icons/empty-list.svg',
                        height: 80,
                        width: 80,
                      ),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

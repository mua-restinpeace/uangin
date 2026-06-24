import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uangin/blocs/get_total_allocated_budgets/get_total_allocated_budgets_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/expense_summary/views/budgets_tab.dart';
import 'package:uangin/features/expense_summary/views/expense_summary_tab.dart';

class SpendingAnalysisScreen extends StatefulWidget {
  final String userId;
  const SpendingAnalysisScreen({required this.userId, super.key});

  @override
  State<SpendingAnalysisScreen> createState() => _SpendingAnalysisScreenState();
}

class _SpendingAnalysisScreenState extends State<SpendingAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
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
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Spending Analysis',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 20),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                  color: MyColors.fillColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: MyColors.lightGrey)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20)),
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: MyColors.grey,
                labelColor: MyColors.black,
                labelStyle: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 16),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    text: 'Expense Summary',
                  ),
                  Tab(
                    text: 'Budgets Allocation',
                  )
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<GetTotalAllocatedBudgetsBloc,
                  GetTotalAllocatedBudgetsState>(
                builder: (context, state) {
                  if (state is GetTotalAllocatedBudgetsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is GetTotalAllocatedBudgetsSuccess) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        ExpenseSummaryScreen(
                            userId: widget.userId,
                            totalAllocated: state.totalAllocated),
                        BudgetsTab(
                          userId: widget.userId,
                        )
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

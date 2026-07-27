import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/allowance_history/blocs/allowance_history/allowance_history_bloc.dart';
import 'package:uangin/features/allowance_history/widget/allowance_list.dart';

class AllowanceHistoryScreen extends StatefulWidget {
  final String userId;
  const AllowanceHistoryScreen({required this.userId, super.key});

  @override
  State<AllowanceHistoryScreen> createState() => _AllowanceHistoryScreenState();
}

class _AllowanceHistoryScreenState extends State<AllowanceHistoryScreen> {
  AllowanceFilter _selectedFilter = AllowanceFilter.thisMonth;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  void _loadTransaction() {
    context
        .read<AllowanceHistoryBloc>()
        .add(GetFilteredAllowance(widget.userId, _selectedFilter));
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
            'Allowance History',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 20),
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24, top: 12),
            child: _buildDropDownButton(context),
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<AllowanceHistoryBloc, AllowanceHistoryState>(
                  builder: (context, allowanceState) {
                    if (allowanceState is AllowanceHistoryLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (allowanceState is AllowanceHistorySuccess) {
                      final grouped = allowanceState.groupedAllowance;
                      if (grouped.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: 0.6,
                                child: SvgPicture.asset(
                                  'lib/assets/icons/empty-list.svg',
                                  width: 128,
                                  height: 128,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                'No allowance found',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildGroupedAllowance(context, grouped);
                    }

                    if (allowanceState is AllowanceHistoryFailure) {
                      return Center(
                        child: Text(
                          'Error loading allowance history',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontSize: 18),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              )
            ],
          )),
    );
  }

  Widget _buildDropDownButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.fillColor,
        border: Border.all(color: MyColors.lightGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<AllowanceFilter>(
            value: _selectedFilter,
            icon: SvgPicture.asset(
              'lib/assets/icons/cevron-down.svg',
              width: 24,
              height: 24,
            ),
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 14),
            borderRadius: BorderRadius.circular(16),
            dropdownColor: MyColors.fillColor,
            onChanged: (AllowanceFilter? neweFilter) {
              if (neweFilter != null) {
                setState(() {
                  _selectedFilter = neweFilter;
                });
              }
              _loadTransaction();
            },
            items: const [
              DropdownMenuItem(
                value: AllowanceFilter.thisMonth,
                child: Text('This Month'),
              ),
              DropdownMenuItem(
                value: AllowanceFilter.lastMonth,
                child: Text('Last Month'),
              ),
              DropdownMenuItem(
                value: AllowanceFilter.thisYear,
                child: Text('This Year'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedAllowance(
      BuildContext context, Map<String, List<Allowances>> grouped) {
    final sortedKeys = grouped.keys.toList()
      ..sort(
        (a, b) {
          final dateA = _parseDateKey(a);
          final dateB = _parseDateKey(b);
          return dateB.compareTo(dateA);
        },
      );

    return ListView.separated(
      itemCount: sortedKeys.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: 24,
      ),
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final allowances = grouped[dateKey]!;
        final date = _parseDateKey(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                DateFormat('EEEE, d MMMM yyyy').format(date),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 16),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: MyColors.fillColor,
                border: Border.all(color: MyColors.lightGrey),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AllowanceList(
                    context: context,
                    allowances: allowances,
                    dateFormat: 'hh.mm a',
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  DateTime _parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(
        int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }
}

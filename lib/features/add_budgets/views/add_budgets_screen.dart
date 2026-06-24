import 'dart:ui';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/blocs/get_total_allocated_budgets/get_total_allocated_budgets_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/animated_circle.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/features/add_budgets/blocs/add_budgets/add_budgets_bloc.dart';

class AddBudgetsScreen extends StatefulWidget {
  final String userId;
  const AddBudgetsScreen({required this.userId, super.key});

  @override
  State<AddBudgetsScreen> createState() => _AddBudgetsScreenState();
}

class _AddBudgetsScreenState extends State<AddBudgetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _allocatedAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            AddBudgetsBloc(context.read<AllowanceRepository>()),
        child: BlocListener<AddBudgetsBloc, AddBudgetsState>(
          listener: (context, state) {
            if (state is AddBudgetsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Budget added successfully!'),
                backgroundColor: MyColors.green,
              ));
              Navigator.pop(context);
            } else if (state is AddBudgetsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Failed to add budgets'),
                backgroundColor: MyColors.red,
              ));
            }
          },
          child: _buildContent(),
        ));
  }

  Widget _buildContent() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'lib/assets/icons/arrow_left.svg',
            width: 32,
            height: 32,
          ),
        ),
        title: Text(
          'Add Budgets',
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const Positioned(
            bottom: 160,
            child: IgnorePointer(
              child: AnimatedCircle(),
            ),
          ),
          const Positioned(
            top: 160,
            right: 60,
            child: IgnorePointer(
              child: AnimatedCircle(),
            ),
          ),
          BlocBuilder<GetTotalAllocatedBudgetsBloc,
              GetTotalAllocatedBudgetsState>(
            builder: (context, state) {
              if (state is GetTotalAllocatedBudgetsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: MyColors.black),
                );
              }

              if (state is GetTotalAllocatedBudgetsSuccess) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewInsets.bottom -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTotalAllocatedAmount(state.totalAllocated),
                              const Spacer(),
                              _buildFormAddBudgets(),
                              const Spacer(),
                              BlocBuilder<AddBudgetsBloc, AddBudgetsState>(
                                builder: (context, budgetState) {
                                  if (budgetState is AddBudgetsLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: MyColors.black,
                                      ),
                                    );
                                  }

                                  return Builder(
                                    builder: (context) {
                                      return LongButton(
                                        text: 'Save',
                                        onPressed: () =>
                                            _handleBudgetAdd(context),
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }

  Widget _buildTotalAllocatedAmount(double totalAllocated) {
    return Container(
      decoration: BoxDecoration(
          color: MyColors.white,
          border: Border.all(color: MyColors.lightGrey),
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: MyColors.black,
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'lib/assets/icons/card.svg',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'IDR',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        MoneyFormatter(amount: totalAllocated).output.nonSymbol,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  Text(
                    'Total allocated',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 16),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFormAddBudgets() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  // color: MyColors.white.withOpacity(1),
                  border: Border.all(
                      color: MyColors.white.withOpacity(0.1), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.white.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 8),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // description
                    TextFormField(
                      controller: _descriptionController,
                      textAlign: TextAlign.center,
                      cursorColor: MyColors.black,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid buduget name';
                        }

                        return null;
                      },
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 18),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: 'Budget name..',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 18, color: MyColors.lightGrey),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // amount field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'IDR',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 24, color: MyColors.grey),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: IntrinsicWidth(
                            child: TextFormField(
                              inputFormatters: [
                                CurrencyTextInputFormatter.currency(
                                  symbol: '',
                                  decimalDigits: 0,
                                )
                              ],
                              controller: _allocatedAmountController,
                              cursorColor: MyColors.black,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 40),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid amount!';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontSize: 40,
                                        color: MyColors.lightGrey,
                                      ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleBudgetAdd(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final rawAmount = _allocatedAmountController.text
          .replaceAll(',', '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .trim();

      final amount = double.tryParse(rawAmount);
      if (amount == null || amount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount!')));
        return;
      }

      final now = DateTime.now();
      final periodStart =
          DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final periodEnd = DateTime(
          now.year, now.month, now.day + (7 - now.weekday), 23, 59, 59, 999);

      context.read<AddBudgetsBloc>().add(AddBudgetSubmitted(
          userId: widget.userId,
          name: _descriptionController.text,
          icon: 'lib/assets/icons/tag_black.svg',
          color: '#888989',
          allocatedAmount: amount,
          periodStart: periodStart,
          periodEnd: periodEnd));
    }
  }
}

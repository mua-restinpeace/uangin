import 'dart:ui';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/features/add_expense/bloc/add_expense/add_expense_bloc.dart';
import 'package:uangin/features/add_expense/bloc/get_budgets/get_budgets_bloc.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';

class AddExpenseScreen extends StatefulWidget {
  final String userId;
  const AddExpenseScreen({required this.userId, super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _innerAnimation;
  late Animation<double> _middleAnimation;
  late Animation<double> _outterAnimation;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  Budgets? _selectedBudgets;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _innerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );

    _middleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    );

    _outterAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetUserBloc, GetUserState>(
      builder: (context, userState) {
        if (userState is! GetUserSuccess) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        MoneyFormatter remainingAllowance =
            MoneyFormatter(amount: userState.user.currentAllowance);

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  AddExpenseBloc(context.read<AllowanceRepository>()),
            ),
            BlocProvider(
              create: (context) =>
                  GetBudgetsBloc(context.read<AllowanceRepository>())
                    ..add(GetBudgets(userState.user.userId)),
            ),
          ],
          child: BlocListener<AddExpenseBloc, AddExpenseState>(
            listener: (context, state) {
              if (state is AddExpenseSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Expense added successfully!'),
                  backgroundColor: MyColors.green,
                ));
                Navigator.pop(context);
              } else if (state is AddExpenseFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add expense: ${state.message!}'),
                    backgroundColor: MyColors.red,
                  ),
                );
              }
            },
            child: _buildContent(remainingAllowance.output.nonSymbol),
          ),
        );
      },
    );
  }

  Widget _buildContent(String allowanceRemaining) {
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
            height: 32,
            width: 32,
          ),
        ),
        title: Text(
          'Add Expense',
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 160,
            // left: -60,
            child: IgnorePointer(child: _buildAnimatedCircle(context)),
          ),
          Positioned(
            top: 160,
            right: 60,
            child: IgnorePointer(child: _buildAnimatedCircle(context)),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    MediaQuery.of(context).viewInsets.bottom,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildAllowanceRemaining(allowanceRemaining),
                        const Spacer(),
                        _buildFormAddExpense(),
                        const Spacer(),
                        _buildCategoriesSelection(),
                        const SizedBox(
                          height: 24,
                        ),
                        BlocBuilder<AddExpenseBloc, AddExpenseState>(
                          builder: (context, state) {
                            if (state is AddExpenseLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Builder(builder: (context) {
                              return LongButton(
                                text: 'Add',
                                onPressed: () => _handleExpenseAdd(context),
                              );
                            });
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 1.6,
            width: MediaQuery.of(context).size.width * 1.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // outter circle
                Transform.scale(
                  scale: 0.8 + (_outterAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _outterAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1.6,
                      width: MediaQuery.of(context).size.width * 1.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.4),
                            blurRadius: 80,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // middle circle
                Transform.scale(
                  scale: 0.8 + (_middleAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _middleAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1.3,
                      width: MediaQuery.of(context).size.width * 1.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            blurRadius: 50,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // inner circle
                Transform.scale(
                  scale: 0.5 + (_innerAnimation.value * 0.5),
                  child: Opacity(
                    opacity: _innerAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildAllowanceRemaining(String allowanceRemaining) {
    return Container(
      decoration: BoxDecoration(
          color: MyColors.white, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: MyColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'lib/assets/icons/card.svg',
                  width: 40,
                  height: 40,
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
                        allowanceRemaining,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  Text(
                    'allowance left',
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

  Widget _buildFormAddExpense() {
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
                    if (_selectedBudgets != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                                '0xFF${_selectedBudgets!.color.replaceAll('#', '')}'),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(
                                int.parse(
                                    '0xFF${_selectedBudgets!.color.replaceAll('#', '')}'),
                              ),
                            )
                          ],
                        ),
                        child: SvgPicture.asset(
                          _selectedBudgets!.icon,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        _selectedBudgets!.name,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                    ],

                    // description
                    TextFormField(
                      controller: _descriptionController,
                      textAlign: TextAlign.center,
                      cursorColor: MyColors.black,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
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
                        hintText: 'What did you buy?',
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
                              controller: _amountController,
                              cursorColor: MyColors.black,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 40),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amunt!';
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

  Widget buildBudgtsChip(Budgets budget) {
    final isSelected = _selectedBudgets?.budgetId == budget.budgetId;
    final color = Color(int.parse('0xFF${budget.color.replaceAll('#', '')}'));
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBudgets = budget;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MyColors.black : MyColors.fillColor,
          border: Border.all(
              color: isSelected ? MyColors.black : MyColors.lightGrey,
              width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? MyColors.primary : color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                budget.icon,
                height: 20,
                width: 20,
                colorFilter: isSelected
                    ? const ColorFilter.mode(
                        MyColors.black,
                        BlendMode.srcIn,
                      )
                    : null,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              budget.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: isSelected ? MyColors.white : MyColors.onPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSelection() {
    return BlocBuilder<GetBudgetsBloc, GetBudgetsState>(
      builder: (context, state) {
        if (state is GetBudgetsLoading) {
          return const SizedBox(
            height: 56,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is GetBudgetsSuccess) {
          if (state.budgetList.isEmpty) {
            return SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'No Budgets Available',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 18),
                ),
              ),
            );
          }
          return SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.budgetList.length,
              separatorBuilder: (context, index) => const SizedBox(
                width: 12,
              ),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return buildBudgtsChip(state.budgetList[index]);
              },
            ),
          );
        }

        return const SizedBox(
          height: 56,
        );
      },
    );
  }

  void _handleExpenseAdd(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedBudgets == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please select budgets for this expense')));
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount')));
        return;
      }

      context.read<AddExpenseBloc>().add(AddExpenseSubmitted(
          userId: widget.userId,
          budgetId: _selectedBudgets!.budgetId,
          budgetName: _selectedBudgets!.name,
          budgetIcon: _selectedBudgets!.icon,
          budgetColor: _selectedBudgets!.color,
          amount: amount,
          date: DateTime.now(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text));
    }
  }
}

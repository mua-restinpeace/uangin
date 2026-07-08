import 'dart:ui';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/animated_circle.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/features/add_saving_goals/bloc/add_saving_goal_bloc/add_saving_goal_bloc_bloc.dart';

class AddSavingGoalsScreen extends StatefulWidget {
  final String userId;
  const AddSavingGoalsScreen({required this.userId, super.key});

  @override
  State<AddSavingGoalsScreen> createState() => _AddSavingGoalsScreenState();
}

class _AddSavingGoalsScreenState extends State<AddSavingGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _targetAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AddSavingGoalBloc(context.read<AllowanceRepository>()),
      child: BlocListener<AddSavingGoalBloc, AddSavingGoalState>(
        listener: (context, state) {
          if (state is AddSavingGoalBlocSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Saving goal added successfully'),
              backgroundColor: MyColors.green,
            ));
            Navigator.pop(context);
          } else if (state is AddSavingGoalBlocFailure) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to add saving goal'),
              backgroundColor: MyColors.red,
            ));
          }
        },
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
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
          'Add Saving Goal',
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
          SafeArea(
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
                        const Spacer(),
                        _buildFormAddGoals(),
                        const Spacer(),
                        BlocBuilder<AddSavingGoalBloc, AddSavingGoalState>(
                          builder: (context, state) {
                            if (state is AddSavingGoalBlocLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: MyColors.black,
                                ),
                              );
                            }

                            return Builder(
                              builder: (context) {
                                return LongButton(
                                    text: 'Add',
                                    onPressed: () => _handleAddGoal(context));
                              },
                            );
                          },
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

  Widget _buildFormAddGoals() {
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
                      controller: _goalNameController,
                      textAlign: TextAlign.center,
                      cursorColor: MyColors.black,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid goal name';
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
                        hintText: 'Goal name..',
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
                              controller: _targetAmountController,
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

  void _handleAddGoal(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final rawAmount = _targetAmountController.text
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

      context.read<AddSavingGoalBloc>().add(AddSavingGoal(
          userId: widget.userId,
          name: _goalNameController.text,
          targetAmount: amount));
    }
  }
}

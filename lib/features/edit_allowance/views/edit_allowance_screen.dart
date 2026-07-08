import 'dart:ui';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/animated_circle.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/features/edit_allowance/blocs/edit_allowance/edit_allowance_bloc.dart';

class EditAllowanceScreen extends StatefulWidget {
  final String userId;
  const EditAllowanceScreen({required this.userId, super.key});

  @override
  State<EditAllowanceScreen> createState() => _EditAllowanceScreenState();
}

class _EditAllowanceScreenState extends State<EditAllowanceScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _updatedAmountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

        MoneyFormatter currentAllowance =
            MoneyFormatter(amount: userState.user.currentAllowance);

        return BlocProvider(
          create: (context) =>
              EditAllowanceBloc(context.read<AllowanceRepository>()),
          child: BlocListener<EditAllowanceBloc, EditAllowanceState>(
            listener: (context, state) {
              if (state is EditAllowanceSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Allowance updated successfully!'),
                  backgroundColor: MyColors.green,
                ));
                Navigator.pop(context);
              } else if (state is EditAllowanceFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Failed to update allowance: ${state.message!}'),
                    backgroundColor: MyColors.red,
                  ),
                );
              }
            },
            child: _buildContent(currentAllowance.output.nonSymbol),
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
          'Edit Allowance',
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const Positioned(
            bottom: 160,
            // left: -60,
            child: IgnorePointer(child: AnimatedCircle()),
          ),
          const Positioned(
            top: 160,
            right: 60,
            child: IgnorePointer(child: AnimatedCircle()),
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
                        _buildCurrentAllowanceCard(allowanceRemaining),
                        const Spacer(),
                        _buildFormEditAllowance(),
                        const Spacer(),
                        BlocBuilder<EditAllowanceBloc, EditAllowanceState>(
                          builder: (context, state) {
                            if (state is EditAllowanceLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: MyColors.black,
                                  strokeCap: StrokeCap.round,
                                ),
                              );
                            }
                            return Builder(builder: (context) {
                              return LongButton(
                                text: 'Save',
                                onPressed: () =>
                                    _handleAllowanceEditSave(context),
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

  Widget _buildCurrentAllowanceCard(String allowanceRemaining) {
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
                        allowanceRemaining,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  Text(
                    'current allowance',
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

  Widget _buildFormEditAllowance() {
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
                    Text(
                      'Enter new allowance amount',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 18),
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
                              controller: _updatedAmountController,
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
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextFormField(
                      controller: _noteController,
                      textAlign: TextAlign.center,
                      cursorColor: MyColors.black,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 18),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: 'notes..',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 18, color: MyColors.lightGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleAllowanceEditSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final rawAmount = _updatedAmountController.text
          .replaceAll('.', '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();

      final amount = double.tryParse(rawAmount);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount')));
        return;
      }

      context.read<EditAllowanceBloc>().add(
            EditAllowanceSubmitted(
                userId: widget.userId,
                targetAmount: amount,
                date: DateTime.now(),
                notes:
                    _noteController.text.isEmpty ? null : _noteController.text),
          );
    }
  }
}

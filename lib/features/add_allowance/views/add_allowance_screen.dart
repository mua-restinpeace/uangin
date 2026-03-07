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
import 'package:uangin/features/add_allowance/blocs/add_allowance/add_allowance_bloc.dart';

class AddAllowanceScreen extends StatefulWidget {
  final String userId;
  final double currentAllowance;

  const AddAllowanceScreen(
      {required this.userId, required this.currentAllowance, super.key});

  @override
  State<AddAllowanceScreen> createState() => _AddAllowanceScreenState();
}

class _AddAllowanceScreenState extends State<AddAllowanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  var _addToSaving = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            AddAllowanceBloc(context.read<AllowanceRepository>()),
        child: BlocListener<AddAllowanceBloc, AddAllowanceState>(
          listener: (context, state) {
            if (state is AddAllowanceSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Allowance added successfully'),
                backgroundColor: MyColors.green,
              ));
              Navigator.pop(context);
            } else if (state is AddAllowanceFailure) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Failed to add allowance'),
                backgroundColor: MyColors.red,
              ));
            }
          },
          child: _buildContent(context, widget.currentAllowance, widget.userId),
        ));
  }

  Widget _buildContent(
      BuildContext context, double currentAllowance, String userId) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            'Add Allowance',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 20),
          ),
        ),
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
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                        _buildAllowanceRemaining(
                          context,
                          currentAllowance,
                        ),
                        const Spacer(),
                        _buildFormAddAllowance(),
                        const Spacer(),
                        BlocBuilder<AddAllowanceBloc, AddAllowanceState>(
                          builder: (context, state) {
                            return Builder(builder: (context) {
                              if(state is AddAllowanceLoading){
                                return const Center(
                                  child: CircularProgressIndicator()
                                );
                              }
                              return LongButton(
                                text: 'Add Allowance',
                                onPressed: () => _handleAllowanceAdd(
                                    context, currentAllowance, userId),
                              );
                            });
                          },
                        )
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

  Widget _buildAllowanceRemaining(
      BuildContext context, double allowanceRemaining) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.fillColor,
        border: Border.all(color: MyColors.lightGrey),
        borderRadius: BorderRadius.circular(16),
      ),
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
                  // description
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
                        MoneyFormatter(amount: allowanceRemaining)
                            .output
                            .nonSymbol,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: allowanceRemaining < 0.0
                                ? MyColors.red
                                : MyColors.onPrimary),
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
            ),
            Row(
              children: [
                Text(
                  'Add to saving',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 14),
                ),
                Checkbox(
                  value: _addToSaving,
                  onChanged: (value) {
                    setState(() {
                      _addToSaving = value ?? false;
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFormAddAllowance() {
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
                    TextFormField(
                      controller: _notesController,
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
                        hintText: 'Add notes',
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

  void _handleAllowanceAdd(
      BuildContext context, double currentAllowance, String userId) {
    if (_formKey.currentState!.validate()) {
      final rawAmount = _amountController.text
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

      if (_addToSaving) {
        if (currentAllowance <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("You don't have any leftover allowance to save!"),
            backgroundColor: MyColors.red,
          ));
          return;
        }
      }

      context.read<AddAllowanceBloc>().add(AddAllowanceSubmitted(
          userId: userId,
          amount: amount,
          currentAllowance: currentAllowance,
          addToSaving: _addToSaving,
          notes: _notesController.text.isEmpty ? null : _notesController.text));
    }
  }
}

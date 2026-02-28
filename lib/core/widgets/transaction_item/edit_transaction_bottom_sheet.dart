
import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/long_button.dart';

class EditTransactionBottomSheet extends StatefulWidget {
  final Transactions transactions;
  final List<Budgets> budgetList;
  final Function(Transactions) onSaved;
  const EditTransactionBottomSheet(
      {required this.transactions,
      required this.budgetList,
      required this.onSaved,
      super.key});

  @override
  State<EditTransactionBottomSheet> createState() =>
      _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState
    extends State<EditTransactionBottomSheet> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late Budgets? _selectedBudgets;
  late DateTime _selectedDateTime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
        text: widget.transactions.amount.toStringAsFixed(0));

    _descriptionController =
        TextEditingController(text: widget.transactions.description ?? '');

    try {
      _selectedBudgets = widget.budgetList
          .firstWhere((b) => b.budgetId == widget.transactions.budgetId);
    } catch (_) {
      _selectedBudgets =
          widget.budgetList.isNotEmpty ? widget.budgetList.first : null;
    }

    _selectedDateTime = widget.transactions.date!;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: MyColors.lightGrey,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // Title
                Text(
                  'Edit Transaction',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(
                  height: 24,
                ),

                // description field
                _buildLabel(context, 'Description'),
                const SizedBox(
                  height: 8,
                ),
                _buildDescriptionField(context),
                const SizedBox(
                  height: 16,
                ),

                // amount field
                _buildLabel(context, 'Amount'),
                const SizedBox(
                  height: 8,
                ),
                _buildAmountField(context),
                const SizedBox(
                  height: 16,
                ),

                // category selector
                _buildLabel(context, 'Category'),
                const SizedBox(
                  height: 8,
                ),
                _buildCategorySelector(context),
                const SizedBox(
                  height: 16,
                ),

                // date selector
                _buildLabel(context, 'Date'),
                const SizedBox(
                  height: 8,
                ),
                _buildDateTimePicker(context),
                const SizedBox(
                  height: 32,
                ),

                SizedBox(
                  width: double.infinity,
                  child: LongButton(
                    text: 'Save Changes',
                    onPressed: _handleSave,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .displayMedium
          ?.copyWith(fontSize: 14, color: MyColors.grey),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.lightGrey),
      ),
      child: TextFormField(
        controller: _descriptionController,
        style:
            Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            hintText: 'What did you buy?',
            hintStyle: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 14, color: MyColors.grey)),
      ),
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: MyColors.fillColor,
          border: Border.all(color: MyColors.lightGrey),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'IDR',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 14, color: MyColors.grey),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _amountController,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Enter amount';
                } else if (double.tryParse(val) == null) {
                  return 'Pleae enter a valid amount';
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.budgetList.length,
        separatorBuilder: (_, __) => const SizedBox(
          width: 8,
        ),
        itemBuilder: (context, index) {
          final budget = widget.budgetList[index];
          final color = Color(
            int.parse('0xFF${budget.color.replaceAll('#', '')}'),
          );
          final isSelected = _selectedBudgets?.budgetId == budget.budgetId;

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
                          color:
                              isSelected ? MyColors.white : MyColors.onPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary)),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDateTime = picked;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MyColors.lightGrey,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/icons/calender.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              DateFormat('EEEE, d MM yyyy').format(_selectedDateTime),
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 14),
            ),
            const Spacer(),
            SvgPicture.asset(
              'lib/assets/icons/cevron.svg',
              width: 24,
              height: 24,
            )
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBudgets == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please select a category')));
      }

      final rawAmount = _amountController.text
          .replaceAll('.', '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();
      final amount = double.tryParse(rawAmount);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount')));
      }

      final updatedTransaction = Transactions(
          transactionId: widget.transactions.transactionId,
          userId: widget.transactions.userId,
          budgetId: _selectedBudgets!.budgetId,
          budgetName: _selectedBudgets!.name,
          budgetIcon: _selectedBudgets!.icon,
          budgetColor: _selectedBudgets!.color,
          amount: amount!,
          date: _selectedDateTime,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          type: widget.transactions.type);

      widget.onSaved(updatedTransaction);
      Navigator.pop(context);
    }
  }
}

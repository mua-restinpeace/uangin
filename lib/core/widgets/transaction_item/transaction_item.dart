import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';

class TransactionItem extends StatefulWidget {
  final Transactions transactions;
  final List<Budgets> budgetList;
  final VoidCallback onDelete;
  final Function(Transactions) onEdited;

  const TransactionItem(
      {required this.transactions,
      required this.budgetList,
      required this.onDelete,
      required this.onEdited,
      super.key});

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(widget.transactions.transactionId),
      closeOnScroll: true,
      endActionPane: ActionPane(
        extentRatio: 0.22,
        dismissible: DismissiblePane(
          onDismissed: widget.onDelete,
          confirmDismiss: () async {
            return await _showDeleteConfimation(context) ?? false;
          },
        ),
        motion: const DrawerMotion(),
        children: [
          CustomSlidableAction(
            autoClose: true,
            onPressed: (slidableContext) async {
              final controller = Slidable.of(slidableContext);
              final confirmation = await _showDeleteConfimation(context);
              if (confirmation == true) {
                controller?.dismiss(ResizeRequest(
                    const Duration(milliseconds: 300), widget.onDelete));
              } else {
                controller?.close();
              }
            },
            backgroundColor: MyColors.red,
            borderRadius: BorderRadius.circular(16),
            padding: EdgeInsets.zero,
            child: SvgPicture.asset(
              'lib/assets/icons/trash.svg',
              width: 28,
              height: 28,
              colorFilter:
                  const ColorFilter.mode(MyColors.white, BlendMode.srcIn),
            ),
          )
        ],
      ),
      child: GestureDetector(
        onTap: () {},
        child: _buildTransactionRow(context),
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context) {
    final color = Color(int.parse(
        '0xFF${widget.transactions.budgetColor.replaceAll('#', '')}'));
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: SvgPicture.asset(
            widget.transactions.budgetIcon,
            height: 24,
            width: 24,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.transactions.description ??
                    widget.transactions.budgetName,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 16),
              ),
              Text(
                widget.transactions.date != null
                    ? DateFormat('EEE, dd MMMM yyyy')
                        .format(widget.transactions.date!)
                    : 'N/A',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14),
              )
            ],
          ),
        ),
        Text(
          'IDR ${MoneyFormatter(amount: widget.transactions.amount).output.nonSymbol}',
          style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(
          width: 12,
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfimation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Transaction',
          style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to delete this transaction? This will also update your budget and allowance.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}

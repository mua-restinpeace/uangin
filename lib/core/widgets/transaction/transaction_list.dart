import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/delete_transaction/delete_transaction_bloc.dart';
import 'package:uangin/blocs/update_transaction/update_transaction_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/transaction/transaction_item.dart';

class TransactionList extends StatelessWidget {
  final BuildContext context;
  final List<Transactions> transactions;
  final List<Budgets> budgets;
  final String? dateFormat;
  const TransactionList(
      {required this.context,
      required this.transactions,
      required this.budgets,
      this.dateFormat,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: transactions.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const Divider(
        color: MyColors.lightGrey,
        thickness: 1,
        height: 24,
      ),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionItem(
          transactions: transaction,
          budgetList: budgets,
          dateFormat: dateFormat,
          onDelete: () {
            context.read<DeleteTransactionBloc>().add(DeleteTransaction(
                transaction.userId, transaction.transactionId));
          },
          onEdited: (updatedTransaction) {
            log('updating transaction: $updatedTransaction');
            context.read<UpdateTransactionBloc>().add(UpdateTransaction(
                updatedTransaction, transaction.amount, transaction.budgetId));
          },
        );
      },
    );
  }
}

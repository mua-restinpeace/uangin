import 'package:allowance_repository/src/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

class Transactions extends Equatable {
  String transactionId;
  String userId;
  String budgetId;
  String budgetName;
  String budgetIcon;
  double amount;
  DateTime? date;
  String? description;
  TransactionType? type;

  Transactions(
      {required this.transactionId,
      required this.userId,
      required this.budgetId,
      required this.budgetName,
      required this.budgetIcon,
      required this.amount,
      required this.date,
      this.description,
      this.type = TransactionType.expense});

  static final empty = Transactions(
      transactionId: '',
      userId: '',
      budgetId: '',
      budgetName: '',
      budgetIcon: '',
      amount: 0,
      date: null,
      description: '',
      type: null);

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  TransactionEntity toEntity() {
    return TransactionEntity(
        transactionId: transactionId,
        userId: userId,
        budgetId: budgetId,
        budgetName: budgetName,
        budgetIcon: budgetIcon,
        amount: amount,
        date: date,
        description: description,
        type: type.toString().split('.').last);
  }

  static Transactions fromEntity(TransactionEntity entity) {
    return Transactions(
        transactionId: entity.transactionId,
        userId: entity.userId,
        budgetId: entity.budgetId,
        budgetName: entity.budgetName,
        budgetIcon: entity.budgetIcon,
        amount: entity.amount,
        date: entity.date,
        description: entity.description,
        type: TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == entity.type,
          orElse: () => TransactionType.expense
        ));
  }

  @override
  String toString() {
    return 'Transactions: $transactionId, $userId, $budgetId, $budgetName, $budgetIcon, $amount, $date, $description, $type';
  }

  @override
  List<Object?> get props => [
        transactionId,
        userId,
        budgetId,
        budgetName,
        budgetIcon,
        amount,
        date,
        description,
        type
      ];
}

enum TransactionType {
  expense,
  income,
  savingsTransfer,
}
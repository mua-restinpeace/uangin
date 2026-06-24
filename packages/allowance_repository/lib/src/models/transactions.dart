import 'package:allowance_repository/src/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

class Transactions extends Equatable {
  String transactionId;
  String userId;
  String budgetId;
  String budgetName;
  String budgetIcon;
  String budgetColor;
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
      required this.budgetColor,
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
      budgetColor: '',
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
        budgetColor: budgetColor,
        amount: amount,
        date: date!,
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
        budgetColor: entity.budgetColor,
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
    return 'Transactions: $transactionId, $userId, $budgetId, $budgetName, $budgetIcon, $budgetColor, $amount, $date, $description, $type';
  }

  @override
  List<Object?> get props => [
        transactionId,
        userId,
        budgetId,
        budgetName,
        budgetIcon,
        budgetColor,
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
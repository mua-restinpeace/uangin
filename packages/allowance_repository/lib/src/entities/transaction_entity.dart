import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionEntity {
  String transactionId;
  String userId;
  String budgetId;
  String budgetName;
  String budgetIcon;
  String budgetColor;
  double amount;
  DateTime date;
  String? description;
  String type;

  TransactionEntity(
      {required this.transactionId,
      required this.userId,
      required this.budgetId,
      required this.budgetName,
      required this.budgetIcon,
      required this.budgetColor,
      required this.amount,
      required this.date,
      this.description,
      required this.type});

  Map<String, Object?> toJSON() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'budgetId': budgetId,
      'budgetName': budgetName,
      'budgetIcon': budgetIcon,
      'budgetColor': budgetColor,
      'amount': amount,
      'date': date,
      'description': description,
      'type': type,
    };
  }

  static TransactionEntity fromJSON(Map<String, dynamic> doc) {
    return TransactionEntity(
        transactionId: doc['transactionId'] as String,
        userId: doc['userId'] as String,
        budgetId: doc['budgetId'] as String,
        budgetName: doc['budgetName'] as String,
        budgetIcon: doc['budgetIcon'] as String,
        budgetColor: doc['budgetColor'] as String,
        amount: (doc['amount'] as num).toDouble(),
        date: (doc['date'] as Timestamp).toDate(),
        description: doc['description'] as String?,
        type: doc['type'] as String);
  }
}

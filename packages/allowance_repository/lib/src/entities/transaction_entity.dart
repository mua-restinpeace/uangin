class TransactionEntity {
  String transactionId;
  String userId;
  String budgetId;
  String budgetName;
  String budgetIcon;
  double amount;
  DateTime? date;
  String? description;
  String type;

  TransactionEntity(
      {required this.transactionId,
      required this.userId,
      required this.budgetId,
      required this.budgetName,
      required this.budgetIcon,
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
        amount: (doc['amount'] as num).toDouble(),
        date: DateTime.fromMillisecondsSinceEpoch(doc['date'] as int),
        description: doc['description'] as String?,
        type: doc['type'] as String);
  }
}

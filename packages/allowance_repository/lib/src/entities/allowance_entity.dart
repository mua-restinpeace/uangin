class AllowanceEntity {
  String allowanceId;
  String userId;
  double amount;
  double savedAmount;
  DateTime? date;
  String? notes;

  AllowanceEntity(
      {required this.allowanceId,
      required this.userId,
      required this.amount,
      required this.date,
      this.savedAmount = 0.0,
      this.notes});

  Map<String, Object?> toJSON(){
    return {
      'allowanceId' : allowanceId,
      'userId' : userId,
      'amount' : amount,
      'savedAmount' : savedAmount,
      'date' : date,
      'notes' : notes
    };
  }

  static AllowanceEntity fromJSON(Map<String, dynamic> doc){
    return AllowanceEntity(
      allowanceId: doc['allowanceId'] as String,
      userId: doc['userId'] as String,
      amount: (doc['amount'] as num).toDouble(),
      savedAmount: (doc['savedAmount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(doc['date'] as int),
      notes: doc['notes'] as String?,
    );
  }
}

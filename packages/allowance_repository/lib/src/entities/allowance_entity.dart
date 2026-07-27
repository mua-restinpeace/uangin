import 'package:cloud_firestore/cloud_firestore.dart';

class AllowanceEntity {
  String allowanceId;
  String userId;
  double amount;
  double savedAmount;
  DateTime? date;
  String? notes;
  String type;

  AllowanceEntity(
      {required this.allowanceId,
      required this.userId,
      required this.amount,
      required this.date,
      this.savedAmount = 0.0,
      this.notes,
      this.type = 'topUp'});

  Map<String, Object?> toJSON() {
    return {
      'allowanceId': allowanceId,
      'userId': userId,
      'amount': amount,
      'savedAmount': savedAmount,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'notes': notes,
      'type': type,
    };
  }

  static AllowanceEntity fromJSON(Map<String, dynamic> doc) {
    return AllowanceEntity(
      allowanceId: doc['allowanceId'] as String,
      userId: doc['userId'] as String,
      amount: (doc['amount'] as num).toDouble(),
      savedAmount: (doc['savedAmount'] as num?)?.toDouble() ?? 0.0,
      date: _dateFromFirebase(doc['date']),
      notes: doc['notes'] as String?,
      type: doc['type'] as String? ?? 'topUp',
    );
  }

  static DateTime? _dateFromFirebase(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    throw FormatException('Invalid date value: $value');
  }
}

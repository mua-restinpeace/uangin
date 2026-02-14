import 'package:allowance_repository/src/entities/allowance_entity.dart';
import 'package:equatable/equatable.dart';

class Allowances extends Equatable {
  String allowanceId;
  String userId;
  double amount;
  double savedAmount;
  DateTime? date;
  String? notes;

  Allowances(
      {required this.allowanceId,
      required this.userId,
      required this.amount,
      required this.date,
      this.savedAmount = 0.0,
      this.notes});

  static final empty =
      Allowances(allowanceId: '', userId: '', amount: 0, date: null);

  bool get isEmpty => this == Allowances.empty;
  bool get isNotEmpty => !isEmpty;

  AllowanceEntity toEnity() {
    return AllowanceEntity(
        allowanceId: allowanceId,
        userId: userId,
        amount: amount,
        date: date,
        savedAmount: savedAmount,
        notes: notes);
  }

  static Allowances fromEntity(AllowanceEntity entity) {
    return Allowances(
        allowanceId: entity.allowanceId,
        userId: entity.userId,
        amount: entity.amount,
        date: entity.date,
        savedAmount: entity.savedAmount,
        notes: entity.notes);
  }

  @override
  String toString() {
    return 'Allowance: $allowanceId, $userId, $amount, $date, $savedAmount, $notes';
  }

  @override
  List<Object?> get props =>
      [allowanceId, userId, amount, savedAmount, date, notes];
}

import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAllowanceRepo implements AllowanceRepository {
  final FirebaseFirestore _firestore;

  FirebaseAllowanceRepo({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // user allowance balance
  @override
  Future<double> getCurrentAllowance(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return 0.0;

      return (doc.data()?['currentAllowance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      log('error getting current allowance: $e');
      rethrow;
    }
  }

  // allowance operations
  @override
  Stream<List<Allowances>> getAllowances(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('allowances')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Allowances.fromEntity(AllowanceEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  @override
  Future<Allowances?> getLatestAllowance(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('allowances')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Allowances.fromEntity(
          AllowanceEntity.fromJSON(snapshot.docs.first.data()));
    } catch (e) {
      log('error getting latets allowance: $e');
      rethrow;
    }
  }

  @override
  Future<Allowances> addAllowance(
      {required String userId,
      required double amount,
      required double currentAllowance,
      required bool addToSaving,
      required DateTime date,
      String? notes}) async {
    try {
      final batch = _firestore.batch();

      // create allowance
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('allowances')
          .doc();

      final allowance = Allowances(
        allowanceId: docRef.id,
        userId: userId,
        amount: amount,
        savedAmount: addToSaving ? currentAllowance : 0.0,
        date: date,
        notes: notes,
        type: AllowanceType.topUp,
      );
      batch.set(docRef, allowance.toEnity().toJSON());

      // update user allowance
      final userRef = _firestore.collection('users').doc(userId);

      if (addToSaving) {
        batch.update(userRef, {
          'currentAllowance': amount,
          'totalSaving': FieldValue.increment(currentAllowance),
          'lastAllowanceDate': Timestamp.fromDate(date)
        });
      } else {
        batch.update(userRef, {
          'currentAllowance': FieldValue.increment(amount),
          'lastAllowanceDate': Timestamp.fromDate(date)
        });
      }

      await batch.commit();

      log('allowance added: ${allowance.allowanceId}');
      return allowance;
    } catch (e) {
      log('error adding allowance: $e');
      rethrow;
    }
  }

  @override
  Future<Allowances> updateCurrentAllowance(
      {required String userId,
      required double targetAmount,
      required DateTime date,
      String? notes}) async {
    try {
      final currentAllowance = await getCurrentAllowance(userId);
      final delta = targetAmount - currentAllowance;

      if (delta == 0) {
        return Allowances(
            allowanceId: '',
            userId: userId,
            amount: 0,
            date: date,
            type: AllowanceType.correction);
      }

      final batch = _firestore.batch();

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('allowances')
          .doc();

      final correction = Allowances(
          allowanceId: docRef.id,
          userId: userId,
          amount: delta,
          savedAmount: 0.0,
          date: date,
          notes: notes,
          type: AllowanceType.correction);

      batch.set(docRef, correction.toEnity().toJSON());

      final userRef = _firestore.collection('users').doc(userId);

      batch.update(userRef, {
        'currentAllowance': targetAmount,
        'lastAllowanceDate': Timestamp.fromDate(date),
      });

      await batch.commit();
      log('allowance corrected: delta=$delta, targetAmount=$targetAmount');
      return correction;
    } catch (e) {
      log('error updating current allowance: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Allowances>> getAllowanceByDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('allowances')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Allowances.fromEntity(AllowanceEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  // budget operations
  @override
  Future<Budgets> createBudget(
      {required String userId,
      required String name,
      required String icon,
      required String color,
      required double allocatedAmount,
      required DateTime periodStart,
      required DateTime periodEnd}) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc();

      final budget = Budgets(
          budgetId: docRef.id,
          userId: userId,
          name: name,
          icon: icon,
          color: color,
          allocatedAmount: allocatedAmount,
          periodStart: periodStart,
          periodEnd: periodEnd,
          isActive: true,
          spentAmount: 0.0);

      await docRef.set(budget.toEnity().toJSON());
      log('budget created: ${budget.budgetId}');
      return budget;
    } catch (e) {
      log('error creating budget: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateBudget(Budgets budget) async {
    try {
      await _firestore
          .collection('users')
          .doc(budget.userId)
          .collection('budgets')
          .doc(budget.budgetId)
          .update(budget.toEnity().toJSON());

      log('budget updated: ${budget.budgetId}');
    } catch (e) {
      log('error updating budget: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(String userId, String budgetId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .delete();

      log('budget deleted: $budgetId');
    } catch (e) {
      log('error deleting budget: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Budgets>> getActiveBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Budgets.fromEntity(BudgetEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  @override
  Future<Budgets?> getBudget(String userId, String budgetId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return Budgets.fromEntity(BudgetEntity.fromJSON(doc.data()!));
    } catch (e) {
      log('error getting budget: $e');
      rethrow;
    }
  }

  @override
  Future<void> udpateBudgetSpentAmount(
      String userId, String budgetId, double amountToAdd) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('budget not found');
        }

        final currentSpent =
            (snapshot.data()?['spentAmount'] as num?)?.toDouble() ?? 0.0;
        final newSpent = currentSpent + amountToAdd;

        transaction.update(docRef, {'spentAmount': newSpent});
      });

      log('budget spent amount added: $budgetId');
    } catch (e) {
      log('error updatig budget spent amount: $e');
      rethrow;
    }
  }

  @override
  Future<void> renewExpiredBudgets(String userId) async {
    try {
      final now = DateTime.now();

      final snapshots = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .where('periodEnd', isLessThan: Timestamp.fromDate(now))
          .get();

      if (snapshots.docs.isEmpty) {
        log('No expired budgets renew');
        return;
      }

      final batch = _firestore.batch();

      for (var doc in snapshots.docs) {
        final budget = Budgets.fromEntity(BudgetEntity.fromJSON(doc.data()));

        final newPeriodStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final newPeriodEnd = newPeriodStart.add(const Duration(
            days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));

        batch.update(doc.reference, {
          'periodStart': Timestamp.fromDate(newPeriodStart),
          'periodEnd': Timestamp.fromDate(newPeriodEnd),
          'spentAmount': 0.0,
        });

        log('renewed budget: ${budget.budgetId}');
      }

      await batch.commit();
      log('Budgets renewed completed for user: $userId');
    } catch (e) {
      log('Error renewing expired budgets');
      rethrow;
    }
  }

  // transaction operations
  @override
  Future<Transactions> addTransaction(
      {required String userId,
      required String budgetId,
      required String budgetName,
      required String budgetIcon,
      required String budgetColor,
      required double amount,
      required DateTime date,
      TransactionType type = TransactionType.expense,
      String? description}) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc();

      final transaction = Transactions(
        transactionId: docRef.id,
        userId: userId,
        budgetId: budgetId,
        budgetName: budgetName,
        budgetIcon: budgetIcon,
        budgetColor: budgetColor,
        amount: amount,
        date: date,
        description: description,
        type: type,
      );

      final batch = _firestore.batch();

      batch.set(docRef, transaction.toEntity().toJSON());

      final budgetRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId);
      batch.update(budgetRef, {'spentAmount': FieldValue.increment(amount)});

      final userRef = _firestore.collection('users').doc(userId);
      batch
          .update(userRef, {'currentAllowance': FieldValue.increment(-amount)});

      await batch.commit();
      log('transaction added: ${transaction.transactionId}');
      return transaction;
    } catch (e) {
      log('error adding transaction: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(
      {required Transactions updatedTransaction,
      required String originalBudgetId,
      required double originalAmount}) async {
    try {
      final batch = _firestore.batch();
      final amountDiff = updatedTransaction.amount - originalAmount;
      final budgetChanged = updatedTransaction.budgetId != originalBudgetId;

      final transactionRef = _firestore
          .collection('users')
          .doc(updatedTransaction.userId)
          .collection('transactions')
          .doc(updatedTransaction.transactionId);
      batch.update(transactionRef, updatedTransaction.toEntity().toJSON());

      if (budgetChanged) {
        final originalBudgetRef = _firestore
            .collection('users')
            .doc(updatedTransaction.userId)
            .collection('budgets')
            .doc(originalBudgetId);
        batch.update(originalBudgetRef,
            {'spentAmount': FieldValue.increment(-originalAmount)});

        final newBudgetRef = _firestore
            .collection('users')
            .doc(updatedTransaction.userId)
            .collection('budgets')
            .doc(updatedTransaction.budgetId);
        batch.update(newBudgetRef,
            {'spentAmount': FieldValue.increment(updatedTransaction.amount)});
      } else if (amountDiff != 0) {
        final updatedBudgetRef = _firestore
            .collection('users')
            .doc(updatedTransaction.userId)
            .collection('budgets')
            .doc(updatedTransaction.budgetId);
        batch.update(updatedBudgetRef,
            {'spentAmount': FieldValue.increment(amountDiff)});
      }

      if (amountDiff != 0) {
        final updatedUserRef =
            _firestore.collection('users').doc(updatedTransaction.userId);
        batch.update(updatedUserRef,
            {'currentAllowance': FieldValue.increment(-amountDiff)});
      }

      await batch.commit();
      log('Transaction updated: $updatedTransaction');
    } catch (e) {
      log('Error update transaction: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Transactions>> getTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Transactions.fromEntity(TransactionEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  @override
  Stream<List<Transactions>> getTransactionByDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Transactions.fromEntity(TransactionEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  @override
  Stream<List<Transactions>> getTransactionByBudget(
      String userId, String budgetId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('budgetId', isEqualTo: budgetId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Transactions.fromEntity(TransactionEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('transaction not found');
      }

      final transaction =
          Transactions.fromEntity(TransactionEntity.fromJSON(doc.data()!));

      final batch = _firestore.batch();
      batch.delete(doc.reference);

      final budgetRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(transaction.budgetId);
      batch.update(budgetRef,
          {'spentAmount': FieldValue.increment(-transaction.amount)});

      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef,
          {'currentAllowance': FieldValue.increment(transaction.amount)});

      await batch.commit();
      log('transaction deleted: ${transaction.transactionId}');
    } catch (e) {
      log('error deleting transaction: $e');
      rethrow;
    }
  }

  // saving goals operations
  @override
  Future<SavingGoals> createdSavingGoal(
      {required String userId,
      required String name,
      String? description,
      String? icon,
      required double targetAmount,
      DateTime? targetDate}) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('savingGoals')
          .doc();

      final goal = SavingGoals(
          goalId: docRef.id,
          userId: userId,
          name: name,
          description: description,
          icon: icon,
          targetAmount: targetAmount,
          currentAmount: 0.0,
          createdDate: DateTime.now(),
          targetDate: targetDate,
          isComplete: false);

      await docRef.set(goal.toEntity().toJSON());
      log('saving goal created: ${goal.goalId}');
      return goal;
    } catch (e) {
      log('error creating saving goal: $e');
      rethrow;
    }
  }

  @override
  Future<double> updateSavingGoalProgress(
      String userId, String goalId, double amountToAdd) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('savingGoals')
          .doc(goalId);

      var excessAmount = 0.0;

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('saving goal not found');
        }

        final data = snapshot.data()!;
        final currentAmount =
            (data['currentAmount'] as num?)?.toDouble() ?? 0.0;
        final targetAmount = (data['targetAmount'] as num).toDouble();
        final remaining = targetAmount - currentAmount;
        final exactAmountToAdd = amountToAdd.clamp(0.00, remaining);
        excessAmount = amountToAdd - exactAmountToAdd;
        final newAmount = currentAmount + exactAmountToAdd;

        final updates = <String, dynamic>{'currentAmount': newAmount};
        final userRef = _firestore.collection('users').doc(userId);

        if (newAmount == targetAmount &&
            !(data['isComplete'] as bool? ?? false)) {
          updates['isComplete'] = true;
          updates['completedDate'] = DateTime.now().millisecondsSinceEpoch;

          transaction
              .update(userRef, {'goalsAchieved': FieldValue.increment(1)});
        }

        transaction.update(docRef, updates);
        transaction.update(
            userRef, {'totalSaving': FieldValue.increment(-exactAmountToAdd)});
      });

      if (excessAmount > 0) {
        return excessAmount;
      }
      log('saving goal updated: $goalId');
      return 0;
    } catch (e) {
      log('error updating saving goal progress: $e');
      rethrow;
    }
  }

  @override
  Stream<List<SavingGoals>> getActiveSavingGoals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savingGoals')
        .where('isComplete', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SavingGoals.fromEntity(SavingGoalEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  @override
  Stream<List<SavingGoals>> getCompletedSavingGoals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savingGoals')
        .where('isComplete', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SavingGoals.fromEntity(SavingGoalEntity.fromJSON(doc.data()));
      }).toList();
    });
  }

  @override
  Future<void> deleteSavingGoal(String userId, String goalId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savingGoals')
          .doc(goalId)
          .delete();

      log('saving goal deleted: $goalId');
    } catch (e) {
      log('error deleting saving goal: $e');
      rethrow;
    }
  }

  // analytics & summary operations
  @override
  Stream<double> getTotalSpentThisPeriod(
      String userId, DateTime periodStart, DateTime periodEnd) {
    try {
      log('getting total spent...');
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd))
          .where('type', isEqualTo: 'expense')
          .snapshots()
          .map((snapshot) {
        double total = 0.0;
        for (var doc in snapshot.docs) {
          total += (doc.data()['amount'] as num).toDouble();
        }

        log('getTotalSpentThisPeriod: total spent amount = $total');
        return total;
      });
    } catch (e) {
      log('error get total spent amount: $e');
      rethrow;
    }
  }

  @override
  Stream<double> getTotalAllocatedBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .snapshots()
        .map((snapshot) {
      double totalAllocated = 0.0;

      for (var doc in snapshot.docs) {
        totalAllocated += (doc.data()['allocatedAmount'] as num).toDouble();
      }

      return totalAllocated;
    });
  }

  @override
  Stream<Map<String, double>> getSpendingBreakdown(
      String userId, DateTime periodStart, DateTime periodEnd) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd))
          .where('type', isEqualTo: 'expense')
          .snapshots()
          .map((snapshot) {
        Map<String, double> breakdown = {};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final budgetName = data['budgetName'] as String;
          final amount = (data['amount'] as num).toDouble();

          breakdown[budgetName] = (breakdown[budgetName] ?? 0.0) + amount;
        }

        return breakdown;
      });
    } catch (e) {
      log('error getting spending breakdown');
      rethrow;
    }
  }
}

import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAllowanceRepo implements AllowanceRepository {
  final FirebaseFirestore _firestore;

  FirebaseAllowanceRepo({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // user allowance balance
  @override
  Future<void> udpateCurrentAllowance(String userId, double newAmount) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'currentAllowance': newAmount});
    } catch (e) {
      log('error updating current allowance: $e');
      rethrow;
    }
  }

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
          .collection('allowance')
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
      double savedAmount = 0.0,
      required DateTime date,
      String? notes}) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('allowances')
          .doc();

      final allowance = Allowances(
          allowanceId: docRef.id,
          userId: userId,
          amount: amount,
          savedAmount: savedAmount,
          date: date,
          notes: notes);

      await docRef.set(allowance.toEnity().toJSON());

      await _updateUserAllowance(userId, amount + savedAmount);

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'lastAllowanceDate': date.millisecondsSinceEpoch});

      log('allowance added: ${allowance.allowanceId}');
      return allowance;
    } catch (e) {
      log('error adding allowance: $e');
      rethrow;
    }
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
      required String icon,
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
  Future<void> updateSavingGoalProgress(
      String userId, String goalId, double amountToAdd) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('savingGoals')
          .doc(goalId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('saving goal not found');
        }

        final data = snapshot.data()!;
        final currentAmount = (data['curentAmount'] as num?)?.toDouble() ?? 0.0;
        final targetAmount = (data['targetAmount'] as num).toDouble();
        final newAmount = currentAmount + amountToAdd;

        final updates = <String, dynamic>{'currentAmount': newAmount};

        if (newAmount >= targetAmount &&
            !(data['isCompleted'] as bool? ?? false)) {
          updates['isCompleted'] = true;
          updates['completedDate'] = DateTime.now().millisecondsSinceEpoch;

          final userRef = _firestore.collection('users').doc(userId);
          transaction
              .update(userRef, {'goalsAchieved': FieldValue.increment(1)});
        }

        transaction.update(docRef, updates);
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'currentAmount': FieldValue.increment(-amountToAdd)});

      log('saving goal updated: $goalId');
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
        .where('isCompleted', isEqualTo: false)
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
        .where('isCompleted', isEqualTo: true)
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
  Future<double> getTotalSpentThisPeriod(
      String userId, DateTime periodStart, DateTime periodEnd) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date',
              isGreaterThanOrEqualTo: periodStart.millisecondsSinceEpoch)
          .where('date', isLessThanOrEqualTo: periodEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: 'expense')
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] as num).toDouble();
      }

      return total;
    } catch (e) {
      log('error get total spent amount: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getSpendingBreakdown(
      String userId, DateTime periodStart, DateTime periodEnd) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date',
              isGreaterThanOrEqualTo: periodStart.millisecondsSinceEpoch)
          .where('date', isLessThanOrEqualTo: periodEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: 'expense')
          .get();

      Map<String, dynamic> breakdown = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final budgetName = data['budgetName'] as String;
        final amount = (data['amount'] as num).toDouble();

        breakdown[budgetName] = (breakdown[budgetName] ?? 0.0) + amount;
      }

      return breakdown;
    } catch (e) {
      log('error getting spending breakdown');
      rethrow;
    }
  }

  Future<void> _updateUserAllowance(String userId, double amountToAdd) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'currentAllowance': FieldValue.increment(amountToAdd)});
  }
}

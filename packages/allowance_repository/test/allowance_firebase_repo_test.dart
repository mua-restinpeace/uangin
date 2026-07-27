import 'package:allowance_repository/allowance_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseAllowanceRepo', () {
    late FakeFirebaseFirestore firestore;
    late FirebaseAllowanceRepo repo;

    const userId = 'test-user-id';

    Future<void> seedUser({
      double currentAllowance = 0.0,
      double totalSaving = 0.0,
      int goalsAchieved = 0,
    }) async {
      await firestore.collection('users').doc(userId).set({
        'currentAllowance': currentAllowance,
        'totalSaving': totalSaving,
        'goalsAchieved': goalsAchieved,
      });
    }

    Future<Budgets> seedBudget({
      String name = 'Food',
      String icon = 'food',
      String color = '#FFAA00',
      double allocatedAmount = 100000,
      DateTime? periodStart,
      DateTime? periodEnd,
    }) {
      return repo.createBudget(
        userId: userId,
        name: name,
        icon: icon,
        color: color,
        allocatedAmount: allocatedAmount,
        periodStart: periodStart ?? DateTime(2026, 6, 1),
        periodEnd: periodEnd ?? DateTime(2026, 6, 30),
      );
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = FirebaseAllowanceRepo(firestore: firestore);
    });

    group('current allowance balance', () {
      test('getCurrentAllowance returns 0 if user document does not exist',
          () async {
        final result = await repo.getCurrentAllowance(userId);

        expect(result, 0.0);
      });

      test('getCurrentAllowance returns currentAllowance from user document',
          () async {
        await seedUser(currentAllowance: 75000);

        final result = await repo.getCurrentAllowance(userId);

        expect(result, 75000);
      });
    });

    group('allowance operations', () {
      test(
        'addAllowance with addToSaving false creates allowance and increments currentAllowance',
        () async {
          await seedUser(currentAllowance: 50000, totalSaving: 0);

          final allowance = await repo.addAllowance(
            userId: userId,
            amount: 100000,
            currentAllowance: 50000,
            addToSaving: false,
            date: DateTime(2026, 6, 25),
            notes: 'Weekly allowance',
          );

          final allowanceSnapshot = await firestore
              .collection('users')
              .doc(userId)
              .collection('allowances')
              .get();

          expect(allowanceSnapshot.docs.length, 1);

          final allowanceData = allowanceSnapshot.docs.first.data();

          expect(allowanceData['allowanceId'], allowance.allowanceId);
          expect(allowanceData['userId'], userId);
          expect(allowanceData['amount'], 100000);
          expect(allowanceData['savedAmount'], 0.0);
          expect(allowanceData['notes'], 'Weekly allowance');
          expect(allowanceData['date'], isA<Timestamp>());

          final userDoc = await firestore.collection('users').doc(userId).get();
          final userData = userDoc.data()!;

          expect(userData['currentAllowance'], 150000);
          expect(userData['totalSaving'], 0);
          expect(userData['lastAllowanceDate'], isA<Timestamp>());
        },
      );

      test(
        'addAllowance with addToSaving true saves leftover allowance and resets currentAllowance to new amount',
        () async {
          await seedUser(currentAllowance: 50000, totalSaving: 10000);

          final allowance = await repo.addAllowance(
            userId: userId,
            amount: 100000,
            currentAllowance: 50000,
            addToSaving: true,
            date: DateTime(2026, 6, 25),
            notes: 'New weekly allowance',
          );

          final allowanceDoc = await firestore
              .collection('users')
              .doc(userId)
              .collection('allowances')
              .doc(allowance.allowanceId)
              .get();

          final allowanceData = allowanceDoc.data()!;

          expect(allowanceData['amount'], 100000);
          expect(allowanceData['savedAmount'], 50000);
          expect(allowance.savedAmount, 50000);

          final userDoc = await firestore.collection('users').doc(userId).get();
          final userData = userDoc.data()!;

          expect(userData['currentAllowance'], 100000);
          expect(userData['totalSaving'], 60000);
          expect(userData['lastAllowanceDate'], isA<Timestamp>());
        },
      );

      test('getAllowances returns allowances sorted newest to oldest',
          () async {
        await seedUser();

        await repo.addAllowance(
          userId: userId,
          amount: 100000,
          currentAllowance: 0,
          addToSaving: false,
          date: DateTime(2026, 6, 1),
        );

        await repo.addAllowance(
          userId: userId,
          amount: 200000,
          currentAllowance: 100000,
          addToSaving: false,
          date: DateTime(2026, 6, 25),
        );

        final allowances = await repo.getAllowances(userId).first;

        expect(allowances.length, 2);
        expect(allowances[0].amount, 200000);
        expect(allowances[1].amount, 100000);
      });

      test('getLatestAllowance returns newest allowance', () async {
        await seedUser();

        await repo.addAllowance(
          userId: userId,
          amount: 100000,
          currentAllowance: 0,
          addToSaving: false,
          date: DateTime(2026, 6, 1),
        );

        await repo.addAllowance(
          userId: userId,
          amount: 250000,
          currentAllowance: 100000,
          addToSaving: true,
          date: DateTime(2026, 6, 25),
        );

        final latest = await repo.getLatestAllowance(userId);

        expect(latest, isNotNull);
        expect(latest!.amount, 250000);
        expect(latest.savedAmount, 100000);
      });

      test(
          'updateCurrentAllowance creates correction entry and sets target balance',
          () async {
        await seedUser(currentAllowance: 150000, totalSaving: 0);

        final correction = await repo.updateCurrentAllowance(
          userId: userId,
          targetAmount: 120000,
          date: DateTime(2026, 6, 26),
          notes: 'Manual correction',
        );

        expect(correction.amount, -30000);
        expect(correction.type, AllowanceType.correction);
        expect(correction.notes, 'Manual correction');

        final userDoc = await firestore.collection('users').doc(userId).get();
        final userData = userDoc.data()!;

        expect(userData['currentAllowance'], 120000);
        expect(userData['lastAllowanceDate'], isA<Timestamp>());

        final allowanceDocs = await firestore
            .collection('users')
            .doc(userId)
            .collection('allowances')
            .get();

        expect(allowanceDocs.docs.length, 1);

        final data = allowanceDocs.docs.first.data();

        expect(data['amount'], -30000);
        expect(data['type'], 'correction');
        expect(data['date'], isA<Timestamp>());
      });

      test(
          'updateCurrentAllowance does not write correction entry when target is unchanged',
          () async {
        await seedUser(currentAllowance: 150000);

        final correction = await repo.updateCurrentAllowance(
          userId: userId,
          targetAmount: 150000,
          date: DateTime(2026, 6, 26),
        );

        expect(correction.allowanceId, '');
        expect(correction.amount, 0);
        expect(correction.type, AllowanceType.correction);

        final allowanceDocs = await firestore
            .collection('users')
            .doc(userId)
            .collection('allowances')
            .get();

        expect(allowanceDocs.docs, isEmpty);
      });

      test(
          'getAllowanceByDateRange returns allowances inside range sorted newest first',
          () async {
        await seedUser();

        await repo.addAllowance(
          userId: userId,
          amount: 100000,
          currentAllowance: 0,
          addToSaving: false,
          date: DateTime(2026, 6, 1),
        );

        await repo.addAllowance(
          userId: userId,
          amount: 200000,
          currentAllowance: 0,
          addToSaving: false,
          date: DateTime(2026, 6, 15),
        );

        await repo.addAllowance(
          userId: userId,
          amount: 300000,
          currentAllowance: 0,
          addToSaving: false,
          date: DateTime(2026, 7, 1),
        );

        final result = await repo
            .getAllowanceByDateRange(
              userId,
              DateTime(2026, 6, 10),
              DateTime(2026, 6, 30, 23, 59, 59),
            )
            .first;

        expect(result.length, 1);
        expect(result.first.amount, 200000);
      });
    });

    group('budget operations', () {
      test('createBudget creates active budget with spentAmount 0', () async {
        await seedUser();

        final budget = await seedBudget(
          name: 'Food',
          icon: 'food',
          color: '#FFAA00',
          allocatedAmount: 300000,
        );

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('budgets')
            .doc(budget.budgetId)
            .get();

        expect(doc.exists, true);

        final data = doc.data()!;

        expect(data['budgetId'], budget.budgetId);
        expect(data['userId'], userId);
        expect(data['name'], 'Food');
        expect(data['icon'], 'food');
        expect(data['color'], '#FFAA00');
        expect(data['allocatedAmount'], 300000);
        expect(data['spentAmount'], 0.0);
        expect(data['isActive'], true);
        expect(data['periodStart'], isA<Timestamp>());
        expect(data['periodEnd'], isA<Timestamp>());
      });

      test('getActiveBudgets returns only active budgets', () async {
        await seedUser();

        final activeBudget = await seedBudget(name: 'Food');

        await firestore
            .collection('users')
            .doc(userId)
            .collection('budgets')
            .doc('inactive-budget-id')
            .set({
          'budgetId': 'inactive-budget-id',
          'userId': userId,
          'name': 'Old Budget',
          'icon': 'old',
          'color': '#000000',
          'allocatedAmount': 10000,
          'spentAmount': 0.0,
          'isActive': false,
          'periodStart': Timestamp.fromDate(DateTime(2026, 5, 1)),
          'periodEnd': Timestamp.fromDate(DateTime(2026, 5, 31)),
        });

        final budgets = await repo.getActiveBudgets(userId).first;

        expect(budgets.length, 1);
        expect(budgets.first.budgetId, activeBudget.budgetId);
        expect(budgets.first.isActive, true);
      });

      test('getBudget returns selected budget', () async {
        await seedUser();

        final budget = await seedBudget(name: 'Transport');

        final result = await repo.getBudget(userId, budget.budgetId);

        expect(result, isNotNull);
        expect(result!.budgetId, budget.budgetId);
        expect(result.name, 'Transport');
      });

      test('updateBudget updates existing budget document', () async {
        await seedUser();

        final budget = await seedBudget(name: 'Food');

        final updatedBudget = Budgets(
          budgetId: budget.budgetId,
          userId: userId,
          name: 'Meals',
          icon: 'meal',
          color: '#00AAFF',
          allocatedAmount: 400000,
          spentAmount: 50000,
          periodStart: DateTime(2026, 6, 1),
          periodEnd: DateTime(2026, 6, 30),
          isActive: true,
        );

        await repo.updateBudget(updatedBudget);

        final result = await repo.getBudget(userId, budget.budgetId);

        expect(result, isNotNull);
        expect(result!.name, 'Meals');
        expect(result.icon, 'meal');
        expect(result.color, '#00AAFF');
        expect(result.allocatedAmount, 400000);
        expect(result.spentAmount, 50000);
      });

      test('udpateBudgetSpentAmount adds amount to spentAmount', () async {
        await seedUser();

        final budget = await seedBudget(allocatedAmount: 300000);

        await repo.udpateBudgetSpentAmount(userId, budget.budgetId, 75000);

        final result = await repo.getBudget(userId, budget.budgetId);

        expect(result, isNotNull);
        expect(result!.spentAmount, 75000);
      });

      test('deleteBudget removes budget document', () async {
        await seedUser();

        final budget = await seedBudget();

        await repo.deleteBudget(userId, budget.budgetId);

        final result = await repo.getBudget(userId, budget.budgetId);

        expect(result, isNull);
      });

      test('renewExpiredBudgets resets spentAmount for expired budgets',
          () async {
        await seedUser();

        final expiredBudget = await seedBudget(
          name: 'Expired Food',
          periodStart: DateTime(2020, 1, 1),
          periodEnd: DateTime(2020, 1, 7),
        );

        await repo.udpateBudgetSpentAmount(
          userId,
          expiredBudget.budgetId,
          50000,
        );

        await repo.renewExpiredBudgets(userId);

        final result = await repo.getBudget(userId, expiredBudget.budgetId);

        expect(result, isNotNull);
        expect(result!.spentAmount, 0.0);
        expect(result.periodEnd!.isAfter(DateTime(2020, 1, 7)), true);
      });
    });

    group('transaction operations', () {
      test('addTransaction creates transaction and updates budget + allowance',
          () async {
        await seedUser(currentAllowance: 500000);

        final budget = await seedBudget(
          name: 'Food',
          icon: 'food',
          color: '#FFAA00',
          allocatedAmount: 300000,
        );

        final transaction = await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 25000,
          date: DateTime(2026, 6, 25),
          description: 'Lunch',
          type: TransactionType.expense,
        );

        final transactionDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transaction.transactionId)
            .get();

        expect(transactionDoc.exists, true);

        final transactionData = transactionDoc.data()!;

        expect(transactionData['amount'], 25000);
        expect(transactionData['description'], 'Lunch');
        expect(transactionData['type'], 'expense');
        expect(transactionData['budgetColor'], '#FFAA00');
        expect(transactionData['date'], isA<Timestamp>());

        final updatedBudget = await repo.getBudget(userId, budget.budgetId);
        expect(updatedBudget!.spentAmount, 25000);

        final currentAllowance = await repo.getCurrentAllowance(userId);
        expect(currentAllowance, 475000);
      });

      test('getTransactions returns transactions sorted newest to oldest',
          () async {
        await seedUser(currentAllowance: 500000);

        final budget = await seedBudget();

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 10000,
          date: DateTime(2026, 6, 1),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 20000,
          date: DateTime(2026, 6, 25),
        );

        final transactions = await repo.getTransactions(userId).first;

        expect(transactions.length, 2);
        expect(transactions[0].amount, 20000);
        expect(transactions[1].amount, 10000);
      });

      test('getTransactionByBudget returns only selected budget transactions',
          () async {
        await seedUser(currentAllowance: 500000);

        final foodBudget = await seedBudget(name: 'Food');
        final transportBudget = await seedBudget(name: 'Transport');

        await repo.addTransaction(
          userId: userId,
          budgetId: foodBudget.budgetId,
          budgetName: foodBudget.name,
          budgetIcon: foodBudget.icon,
          budgetColor: foodBudget.color,
          amount: 10000,
          date: DateTime(2026, 6, 10),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: transportBudget.budgetId,
          budgetName: transportBudget.name,
          budgetIcon: transportBudget.icon,
          budgetColor: transportBudget.color,
          amount: 20000,
          date: DateTime(2026, 6, 11),
        );

        final result = await repo
            .getTransactionByBudget(userId, foodBudget.budgetId)
            .first;

        expect(result.length, 1);
        expect(result.first.budgetId, foodBudget.budgetId);
        expect(result.first.amount, 10000);
      });

      test('getTransactionByDateRange returns transactions inside range',
          () async {
        await seedUser(currentAllowance: 500000);

        final budget = await seedBudget();

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 10000,
          date: DateTime(2026, 6, 1),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 20000,
          date: DateTime(2026, 6, 15),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 30000,
          date: DateTime(2026, 7, 1),
        );

        final result = await repo
            .getTransactionByDateRange(
              userId,
              DateTime(2026, 6, 10),
              DateTime(2026, 6, 30, 23, 59, 59),
            )
            .first;

        expect(result.length, 1);
        expect(result.first.amount, 20000);
      });

      test(
          'updateTransaction adjusts budget and currentAllowance by difference',
          () async {
        await seedUser(currentAllowance: 500000);

        final budget = await seedBudget();

        final transaction = await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 25000,
          date: DateTime(2026, 6, 25),
          description: 'Lunch',
        );

        final updatedTransaction = Transactions(
          transactionId: transaction.transactionId,
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 40000,
          date: DateTime(2026, 6, 25),
          description: 'Lunch updated',
          type: TransactionType.expense,
        );

        await repo.updateTransaction(
          updatedTransaction: updatedTransaction,
          originalBudgetId: budget.budgetId,
          originalAmount: 25000,
        );

        final updatedBudget = await repo.getBudget(userId, budget.budgetId);
        expect(updatedBudget!.spentAmount, 40000);

        final currentAllowance = await repo.getCurrentAllowance(userId);
        expect(currentAllowance, 460000);
      });

      test(
          'deleteTransaction removes transaction and restores budget + allowance',
          () async {
        await seedUser(currentAllowance: 500000);

        final budget = await seedBudget();

        final transaction = await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 25000,
          date: DateTime(2026, 6, 25),
        );

        await repo.deleteTransaction(userId, transaction.transactionId);

        final transactionDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transaction.transactionId)
            .get();

        expect(transactionDoc.exists, false);

        final updatedBudget = await repo.getBudget(userId, budget.budgetId);
        expect(updatedBudget!.spentAmount, 0.0);

        final currentAllowance = await repo.getCurrentAllowance(userId);
        expect(currentAllowance, 500000);
      });
    });

    group('saving goal operations', () {
      test('createdSavingGoal creates incomplete saving goal', () async {
        await seedUser();

        final goal = await repo.createdSavingGoal(
          userId: userId,
          name: 'Buy Laptop',
          description: 'For coding',
          icon: 'laptop',
          targetAmount: 5000000,
          targetDate: DateTime(2026, 12, 31),
        );

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('savingGoals')
            .doc(goal.goalId)
            .get();

        expect(doc.exists, true);

        final data = doc.data()!;

        expect(data['goalId'], goal.goalId);
        expect(data['userId'], userId);
        expect(data['name'], 'Buy Laptop');
        expect(data['description'], 'For coding');
        expect(data['icon'], 'laptop');
        expect(data['targetAmount'], 5000000);
        expect(data['currentAmount'], 0.0);
        expect(data['isComplete'], false);
        expect(data['createdDate'], isA<Timestamp>());
        expect(data['targetDate'], isA<Timestamp>());
      });

      test('getActiveSavingGoals returns incomplete goals', () async {
        await seedUser();

        await repo.createdSavingGoal(
          userId: userId,
          name: 'Buy Laptop',
          icon: 'laptop',
          targetAmount: 5000000,
        );

        final result = await repo.getActiveSavingGoals(userId).first;

        expect(result.length, 1);
        expect(result.first.name, 'Buy Laptop');
        expect(result.first.isComplete, false);
      });

      test('updateSavingGoalProgress increases currentAmount', () async {
        await seedUser(currentAllowance: 500000, totalSaving: 500000);

        final goal = await repo.createdSavingGoal(
          userId: userId,
          name: 'Emergency Fund',
          icon: 'wallet',
          targetAmount: 1000000,
        );

        await repo.updateSavingGoalProgress(userId, goal.goalId, 250000);

        final goalDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('savingGoals')
            .doc(goal.goalId)
            .get();

        final goalData = goalDoc.data()!;

        expect(goalData['currentAmount'], 250000);
        expect(goalData['isComplete'], false);
      });

      test('updateSavingGoalProgress completes goal when target is reached',
          () async {
        await seedUser(currentAllowance: 1000000, totalSaving: 1000000);

        final goal = await repo.createdSavingGoal(
          userId: userId,
          name: 'New Phone',
          icon: 'phone',
          targetAmount: 500000,
        );

        await repo.updateSavingGoalProgress(userId, goal.goalId, 500000);

        final goalDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('savingGoals')
            .doc(goal.goalId)
            .get();

        final goalData = goalDoc.data()!;

        expect(goalData['currentAmount'], 500000);
        expect(goalData['isComplete'], true);

        expect(goalData['completedDate'], isA<Timestamp>());

        final userDoc = await firestore.collection('users').doc(userId).get();
        expect(userDoc.data()!['goalsAchieved'], 1);
      });

      test('getCompletedSavingGoals returns completed goals', () async {
        await seedUser(currentAllowance: 1000000, totalSaving: 1000000);

        final goal = await repo.createdSavingGoal(
          userId: userId,
          name: 'New Phone',
          icon: 'phone',
          targetAmount: 500000,
        );

        await repo.updateSavingGoalProgress(userId, goal.goalId, 500000);

        final result = await repo.getCompletedSavingGoals(userId).first;

        expect(result.length, 1);
        expect(result.first.name, 'New Phone');
        expect(result.first.isComplete, true);
      });

      test('deleteSavingGoal removes saving goal document', () async {
        await seedUser();

        final goal = await repo.createdSavingGoal(
          userId: userId,
          name: 'Trip',
          icon: 'travel',
          targetAmount: 1500000,
        );

        await repo.deleteSavingGoal(userId, goal.goalId);

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('savingGoals')
            .doc(goal.goalId)
            .get();

        expect(doc.exists, false);
      });

      test('updateSavingGoalProgress deducts allocated amount from totalSaving',
          () async {
        await seedUser(currentAllowance: 500000, totalSaving: 500000);

        final goal = await repo.createdSavingGoal(
          userId: userId,
          name: 'Emergency Fund',
          icon: 'wallet',
          targetAmount: 1000000,
        );

        final excess = await repo.updateSavingGoalProgress(
          userId,
          goal.goalId,
          250000,
        );

        expect(excess, 0);

        final userDoc = await firestore.collection('users').doc(userId).get();
        expect(userDoc.data()!['totalSaving'], 250000);
      });

      test(
          'updateSavingGoalProgress returns excess and only deducts remaining target amount',
          () async {
        await seedUser(currentAllowance: 1000000, totalSaving: 1000000);

        final goal = await repo.createdSavingGoal(
          userId: userId,
          name: 'Phone',
          icon: 'phone',
          targetAmount: 500000,
        );

        final excess = await repo.updateSavingGoalProgress(
          userId,
          goal.goalId,
          700000,
        );

        expect(excess, 200000);

        final goalDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('savingGoals')
            .doc(goal.goalId)
            .get();

        expect(goalDoc.data()!['currentAmount'], 500000);
        expect(goalDoc.data()!['isComplete'], true);

        final userDoc = await firestore.collection('users').doc(userId).get();
        expect(userDoc.data()!['totalSaving'], 500000);
      });
    });

    group('analytics and summary operations', () {
      test('getTotalSpentThisPeriod returns total expense amount in period',
          () async {
        await seedUser(currentAllowance: 1000000);

        final budget = await seedBudget(name: 'Food');

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 10000,
          date: DateTime(2026, 6, 1),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 20000,
          date: DateTime(2026, 6, 15),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: budget.budgetId,
          budgetName: budget.name,
          budgetIcon: budget.icon,
          budgetColor: budget.color,
          amount: 30000,
          date: DateTime(2026, 7, 1),
        );

        final total = await repo
            .getTotalSpentThisPeriod(
              userId,
              DateTime(2026, 6, 1),
              DateTime(2026, 6, 30, 23, 59, 59),
            )
            .first;

        expect(total, 30000);
      });

      test('getTotalAllocatedBudgets returns sum of allocated budgets',
          () async {
        await seedUser();

        await seedBudget(name: 'Food', allocatedAmount: 300000);
        await seedBudget(name: 'Transport', allocatedAmount: 150000);

        final total = await repo.getTotalAllocatedBudgets(userId).first;

        expect(total, 450000);
      });

      test('getSpendingBreakdown groups total expense by budget name',
          () async {
        await seedUser(currentAllowance: 1000000);

        final foodBudget = await seedBudget(name: 'Food');
        final transportBudget = await seedBudget(name: 'Transport');

        await repo.addTransaction(
          userId: userId,
          budgetId: foodBudget.budgetId,
          budgetName: foodBudget.name,
          budgetIcon: foodBudget.icon,
          budgetColor: foodBudget.color,
          amount: 10000,
          date: DateTime(2026, 6, 1),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: foodBudget.budgetId,
          budgetName: foodBudget.name,
          budgetIcon: foodBudget.icon,
          budgetColor: foodBudget.color,
          amount: 15000,
          date: DateTime(2026, 6, 2),
        );

        await repo.addTransaction(
          userId: userId,
          budgetId: transportBudget.budgetId,
          budgetName: transportBudget.name,
          budgetIcon: transportBudget.icon,
          budgetColor: transportBudget.color,
          amount: 20000,
          date: DateTime(2026, 6, 3),
        );

        final breakdown = await repo
            .getSpendingBreakdown(
              userId,
              DateTime(2026, 6, 1),
              DateTime(2026, 6, 30, 23, 59, 59),
            )
            .first;

        expect(breakdown['Food'], 25000);
        expect(breakdown['Transport'], 20000);
      });
    });
  });
}

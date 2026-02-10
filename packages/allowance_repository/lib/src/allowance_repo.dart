import 'package:allowance_repository/allowance_repository.dart';

abstract class AllowanceRepository {
  // user allowance balance
  Future<double> getCurrentAllowance(String userId);
  Future<void> udpateCurrentAllowance(String userId, double newAmount);

  // allowance operations
  Future<Allowances> addAllowance(
      {required String userId,
      required double amount,
      double savedAmount,
      required DateTime date,
      String? notes});
  Stream<List<Allowances>> getAllowances(String userId);
  Future<Allowances?> getLatestAllowance(String userId);

  // budget operations
  Future<Budgets> createBudget(
      {required String userId,
      required String name,
      required String icon,
      required double allocatedAmount,
      required DateTime periodStart,
      required DateTime periodEnd});
  Future<void> updateBudget(Budgets budget);
  Future<void> deleteBudget(String userId, String budgetId);
  Stream<List<Budgets>> getActiveBudgets(String userId);
  Future<Budgets?> getBudget(String userId, String budgetId);
  Future<void> udpateBudgetSpentAmount(
      String userId, String budgetId, double amountToAdd);

  // transaction operation
  Future<Transactions> addTransaction(
      {required String userId,
      required String budgetId,
      required String budgetName,
      required String budgetIcon,
      required double amount,
      required DateTime date,
      TransactionType type = TransactionType.expense,
      String? description});
  Stream<List<Transactions>> getTransactions(String userId);
  Stream<List<Transactions>> getTransactionByDateRange(
      String userId, DateTime startDate, DateTime endDate);
  Stream<List<Transactions>> getTransactionByBudget(
      String userId, String budgetId);
  Future<void> deleteTransaction(String userId, String transactionId);

  // saving goal operations
  Future<SavingGoals> createdSavingGoal(
      {required String userId,
      required String name,
      String? description,
      required String icon,
      required double targetAmount,
      DateTime? targetDate});
  Future<void> updateSavingGoalProgress(
      String userId, String goalId, double amountToAdd);
  Stream<List<SavingGoals>> getActiveSavingGoals(String userId);
  Stream<List<SavingGoals>> getCompletedSavingGoals(String userId);
  Future<void> deleteSavingGoal(String userId, String goalId);

  // analytics & summary operations
  Future<double> getTotalSpentThisPeriod(
    String userId,
    DateTime periodStart,
    DateTime periodEnd,
  );
  Future<Map<String, dynamic>> getSpendingBreakdown(
      String userId, DateTime periodStart, DateTime periodEnd);
}

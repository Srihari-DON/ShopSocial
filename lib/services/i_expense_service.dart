import '../models/expense.dart';

abstract class IExpenseService {
  Future<List<Expense>> getExpensesForEvent(String eventId);
  Future<Expense> createExpense(Expense expense);
  Future<Expense> updateExpense(String id, Map<String, dynamic> data);
  Future<void> deleteExpense(String id);
  Future<void> markAsPaid(String expenseId, String userId);
  Future<Map<String, double>> getBalances(String eventId);
}

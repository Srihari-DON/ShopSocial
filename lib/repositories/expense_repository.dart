import '../models/expense.dart';
import '../services/i_expense_service.dart';

class ExpenseRepository {
  final IExpenseService _expenseService;
  
  ExpenseRepository(this._expenseService);
  
  Future<List<Expense>> getExpensesForEvent(String eventId) {
    return _expenseService.getExpensesForEvent(eventId);
  }
  
  Future<Expense> createExpense(Expense expense) {
    return _expenseService.createExpense(expense);
  }
  
  Future<Expense> updateExpense(String id, Map<String, dynamic> data) {
    return _expenseService.updateExpense(id, data);
  }
  
  Future<void> deleteExpense(String id) {
    return _expenseService.deleteExpense(id);
  }
  
  Future<void> markAsPaid(String expenseId, String userId) {
    return _expenseService.markAsPaid(expenseId, userId);
  }
  
  Future<Map<String, double>> getBalances(String eventId) {
    return _expenseService.getBalances(eventId);
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/expense.dart';
import 'i_expense_service.dart';

class ExpenseServiceMock implements IExpenseService {
  late List<Expense> _expenses;
  
  ExpenseServiceMock() {
    _loadExpenses();
  }
  
  Future<void> _loadExpenses() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/mock_data/expenses.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _expenses = jsonList.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      // If file doesn't exist yet, create placeholder data
      _expenses = [
        Expense(
          id: 'exp1',
          eventId: 'e1',
          createdBy: 'u1',
          description: 'Pizza and snacks',
          amount: 45.50,
          currency: 'USD',
          shares: {
            'u1': 15.50,
            'u2': 15.00,
            'u3': 15.00,
          },
          paid: {
            'u1': true,
            'u2': false,
            'u3': false,
          },
        ),
        Expense(
          id: 'exp2',
          eventId: 'e2',
          createdBy: 'u2',
          description: 'Campsite reservation',
          amount: 120.00,
          currency: 'USD',
          shares: {
            'u1': 40.00,
            'u2': 40.00,
            'u4': 40.00,
          },
          paid: {
            'u1': true,
            'u2': true,
            'u4': false,
          },
        ),
      ];
    }
  }
  
  @override
  Future<List<Expense>> getExpensesForEvent(String eventId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    return _expenses.where((expense) => expense.eventId == eventId).toList();
  }
  
  @override
  Future<Expense> createExpense(Expense expense) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    // Verify that shares add up to the total amount
    final total = expense.shares.values.fold<double>(0, (sum, amount) => sum + amount);
    if ((total - expense.amount).abs() > 0.01) {
      throw Exception('Shares must add up to the total amount');
    }
    
    // Create new expense with generated ID
    final newExpense = Expense(
      id: 'exp${_expenses.length + 1}',
      eventId: expense.eventId,
      createdBy: expense.createdBy,
      description: expense.description,
      amount: expense.amount,
      currency: expense.currency,
      shares: expense.shares,
      paid: expense.paid,
    );
    
    _expenses.add(newExpense);
    return newExpense;
  }
  
  @override
  Future<Expense> updateExpense(String id, Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final expenseIndex = _expenses.indexWhere((expense) => expense.id == id);
    if (expenseIndex == -1) {
      throw Exception('Expense not found');
    }
    
    final currentExpense = _expenses[expenseIndex];
    
    // Prepare the updated data
    final double amount = data['amount'] ?? currentExpense.amount;
    final Map<String, double> shares = data['shares'] ?? currentExpense.shares;
    
    // Verify that shares add up to the total amount if both are changing
    if (data['amount'] != null && data['shares'] != null) {
      final total = shares.values.fold<double>(0, (sum, value) => sum + value);
      if ((total - amount).abs() > 0.01) {
        throw Exception('Shares must add up to the total amount');
      }
    }
    
    // Create updated expense
    final updatedExpense = Expense(
      id: currentExpense.id,
      eventId: currentExpense.eventId,
      createdBy: currentExpense.createdBy,
      description: data['description'] ?? currentExpense.description,
      amount: amount,
      currency: data['currency'] ?? currentExpense.currency,
      shares: shares,
      paid: data['paid'] ?? currentExpense.paid,
    );
    
    _expenses[expenseIndex] = updatedExpense;
    return updatedExpense;
  }
  
  @override
  Future<void> deleteExpense(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    _expenses.removeWhere((expense) => expense.id == id);
  }
  
  @override
  Future<void> markAsPaid(String expenseId, String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final expenseIndex = _expenses.indexWhere((expense) => expense.id == expenseId);
    if (expenseIndex == -1) {
      throw Exception('Expense not found');
    }
    
    final expense = _expenses[expenseIndex];
    
    // Check if user has a share in this expense
    if (!expense.shares.containsKey(userId)) {
      throw Exception('User does not have a share in this expense');
    }
    
    // Update paid status
    final updatedPaid = Map<String, bool>.from(expense.paid);
    updatedPaid[userId] = true;
    
    _expenses[expenseIndex] = Expense(
      id: expense.id,
      eventId: expense.eventId,
      createdBy: expense.createdBy,
      description: expense.description,
      amount: expense.amount,
      currency: expense.currency,
      shares: expense.shares,
      paid: updatedPaid,
    );
  }
  
  @override
  Future<Map<String, double>> getBalances(String eventId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    // Get all expenses for the event
    final eventExpenses = await getExpensesForEvent(eventId);
    
    // Calculate net balance for each user
    final balances = <String, double>{};
    
    for (final expense in eventExpenses) {
      // Add to the creator's balance (positive means owed money)
      balances[expense.createdBy] = (balances[expense.createdBy] ?? 0) + expense.amount;
      
      // Subtract shares from each user's balance
      expense.shares.forEach((userId, amount) {
        if (expense.paid[userId] == true) {
          // If already paid, don't count it
          return;
        }
        
        balances[userId] = (balances[userId] ?? 0) - amount;
      });
    }
    
    return balances;
  }
}

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/expense.dart';
import '../models/user.dart';
import '../repositories/expense_repository.dart';
import '../repositories/user_repository.dart';
import '../services/expense_service_mock.dart';
import 'auth_vm.dart';

// Expense state
class ExpenseState {
  final List<Expense> expenses;
  final Map<String, User> users;
  final Map<String, double> balances;
  final bool isLoading;
  final String? error;
  
  ExpenseState({
    this.expenses = const [],
    this.users = const {},
    this.balances = const {},
    this.isLoading = false,
    this.error,
  });
  
  ExpenseState copyWith({
    List<Expense>? expenses,
    Map<String, User>? users,
    Map<String, double>? balances,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      users: users ?? this.users,
      balances: balances ?? this.balances,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Expense ViewModel
class ExpenseVM extends StateNotifier<ExpenseState> {
  final ExpenseRepository _expenseRepository;
  final UserRepository _userRepository;
  final String eventId;
  final User? _currentUser;
  
  ExpenseVM(
    this._expenseRepository,
    this._userRepository,
    this.eventId,
    this._currentUser,
  ) : super(ExpenseState()) {
    loadExpenses();
  }
  
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final expenses = await _expenseRepository.getExpensesForEvent(eventId);
      
      // Extract unique user IDs
      final userIds = <String>{};
      for (final expense in expenses) {
        userIds.add(expense.createdBy);
        userIds.addAll(expense.shares.keys);
      }
      
      // Fetch user details
      final users = await _userRepository.getUsersByIds(userIds.toList());
      final usersMap = {for (var user in users) user.id: user};
      
      // Get balances
      final balances = await _expenseRepository.getBalances(eventId);
      
      state = state.copyWith(
        expenses: expenses,
        users: usersMap,
        balances: balances,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> createExpense(Expense expense) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final newExpense = await _expenseRepository.createExpense(expense);
      
      // Add any new users that might be in the expense
      final userIds = <String>{
        newExpense.createdBy,
        ...newExpense.shares.keys,
      }..removeWhere((id) => state.users.containsKey(id));
      
      Map<String, User> updatedUsers = Map.from(state.users);
      if (userIds.isNotEmpty) {
        final users = await _userRepository.getUsersByIds(userIds.toList());
        for (final user in users) {
          updatedUsers[user.id] = user;
        }
      }
      
      // Update balances
      final balances = await _expenseRepository.getBalances(eventId);
      
      state = state.copyWith(
        expenses: [...state.expenses, newExpense],
        users: updatedUsers,
        balances: balances,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final updatedExpense = await _expenseRepository.updateExpense(id, data);
      
      final updatedExpenses = state.expenses.map((expense) {
        return expense.id == id ? updatedExpense : expense;
      }).toList();
      
      // Update balances
      final balances = await _expenseRepository.getBalances(eventId);
      
      state = state.copyWith(
        expenses: updatedExpenses,
        balances: balances,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _expenseRepository.deleteExpense(id);
      
      final updatedExpenses = state.expenses.where((expense) => expense.id != id).toList();
      
      // Update balances
      final balances = await _expenseRepository.getBalances(eventId);
      
      state = state.copyWith(
        expenses: updatedExpenses,
        balances: balances,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> markAsPaid(String expenseId) async {
    if (_currentUser == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      await _expenseRepository.markAsPaid(expenseId, _currentUser!.id);
      
      // Update the expense locally
      final updatedExpenses = state.expenses.map((expense) {
        if (expense.id == expenseId) {
          final updatedPaid = Map<String, bool>.from(expense.paid);
          updatedPaid[_currentUser!.id] = true;
          
          return Expense(
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
        return expense;
      }).toList();
      
      // Update balances
      final balances = await _expenseRepository.getBalances(eventId);
      
      state = state.copyWith(
        expenses: updatedExpenses,
        balances: balances,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Helper methods
  
  // Get the total amount of expenses
  double get totalExpensesAmount {
    return state.expenses.fold(0, (total, expense) => total + expense.amount);
  }
  
  // Get balance for current user
  double get currentUserBalance {
    if (_currentUser == null) return 0;
    return state.balances[_currentUser!.id] ?? 0;
  }
  
  // Is expense created by current user
  bool isExpenseCreatedByCurrentUser(String expenseId) {
    if (_currentUser == null) return false;
    
    final expense = state.expenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => Expense(
        id: '',
        eventId: '',
        createdBy: '',
        description: '',
        amount: 0,
        currency: 'USD',
        shares: {},
        paid: {},
      ),
    );
    
    return expense.createdBy == _currentUser!.id;
  }
  
  // Has current user paid for an expense
  bool hasCurrentUserPaid(String expenseId) {
    if (_currentUser == null) return false;
    
    final expense = state.expenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => Expense(
        id: '',
        eventId: '',
        createdBy: '',
        description: '',
        amount: 0,
        currency: 'USD',
        shares: {},
        paid: {},
      ),
    );
    
    return expense.paid[_currentUser!.id] == true;
  }
  
  // Get user's share in an expense
  double getUserShare(String expenseId, String userId) {
    final expense = state.expenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => Expense(
        id: '',
        eventId: '',
        createdBy: '',
        description: '',
        amount: 0,
        currency: 'USD',
        shares: {},
        paid: {},
      ),
    );
    
    return expense.shares[userId] ?? 0;
  }
}

// Provider factory for ExpenseVM instances
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ExpenseServiceMock());
});

final expenseVMProvider = StateNotifierProvider.family<ExpenseVM, ExpenseState, String>((ref, eventId) {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final authState = ref.watch(authVMProvider);
  
  return ExpenseVM(
    expenseRepository,
    userRepository,
    eventId,
    authState.currentUser,
  );
});

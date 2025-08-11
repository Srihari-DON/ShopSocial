class Expense {
  final String id;
  final String eventId;
  final String createdBy;
  final String description;
  final double amount;
  final String currency;
  final Map<String, double> shares; // userId -> share amount
  final Map<String, bool> paid; // userId -> paid boolean
  
  Expense({
    required this.id,
    required this.eventId,
    required this.createdBy,
    required this.description,
    required this.amount,
    required this.currency,
    required this.shares,
    required this.paid,
  });
  
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      createdBy: json['createdBy'] as String,
      description: json['description'] as String,
      amount: json['amount'] as double,
      currency: json['currency'] as String,
      shares: Map<String, double>.from(
        Map.fromEntries((json['shares'] as Map<String, dynamic>).entries
            .map((e) => MapEntry(e.key, e.value as double))),
      ),
      paid: Map<String, bool>.from(
        Map.fromEntries((json['paid'] as Map<String, dynamic>).entries
            .map((e) => MapEntry(e.key, e.value as bool))),
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'createdBy': createdBy,
      'description': description,
      'amount': amount,
      'currency': currency,
      'shares': shares,
      'paid': paid,
    };
  }
}

import '../enums/transaction_type_enum.dart';

class Transaction {
  final int amount;
  final DateTime timestamp;
  final TransactionType type;
  final String? bussId;

  Transaction({
    required this.amount,
    required this.timestamp,
    required this.type,
    this.bussId,
  });

  // default object for Transaction
  factory Transaction.defaultObj() => Transaction(
    amount: 0,
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    type: TransactionType.credit,
    bussId: null,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: (json['amount'] ?? 0) as int,
      timestamp:
          DateTime.tryParse(json['timestamp'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: TransactionType.values.firstWhere(
        (e) => e.name == (json['type'] ?? '').toString(),
        orElse: () => TransactionType.credit,
      ),
      bussId: (json['bussId'] ?? '').toString().isNotEmpty
          ? (json['bussId'] ?? '').toString()
          : null,
    );
  }
}

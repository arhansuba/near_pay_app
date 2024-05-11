
import 'package:near_pay_app/core/models/transaction.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0

class CachedTransaction {
  final String id;
  final Transaction transaction;
  final DateTime timestamp;

  CachedTransaction({
    required this.id,
    required this.transaction,
    required this.timestamp,
  });

  factory CachedTransaction.fromJson(Map<String, dynamic> json) {
    return CachedTransaction(
      id: json['id'] as String,
      transaction: Transaction.fromJson(json['transaction'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction': transaction.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class CachedTransactionList {
  final List<CachedTransaction> transactions;

  CachedTransactionList({required this.transactions});

  factory CachedTransactionList.fromJson(List<dynamic> json) {
    return CachedTransactionList(
      transactions: json.map((e) => CachedTransaction.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return transactions.map((e) => e.toJson()).toList();
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.balanceAfterCents,
    required this.note,
    this.createdAt,
  });
  final String id, type, note;
  final int amountCents, balanceAfterCents;
  final DateTime? createdAt;
  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        amountCents: (json['amountCents'] as num? ?? 0).toInt(),
        balanceAfterCents: (json['balanceAfterCents'] as num? ?? 0).toInt(),
        note: json['note'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );
}

class WalletSummary {
  const WalletSummary({required this.balanceCents, required this.transactions});
  final int balanceCents;
  final List<WalletTransaction> transactions;
  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
    balanceCents: (json['balanceCents'] as num? ?? 0).toInt(),
    transactions: (json['transactions'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(WalletTransaction.fromJson)
        .toList(),
  );
}

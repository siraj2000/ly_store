class WalletTransactionModel {
  const WalletTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.title = '',
    this.customerId = '',
    this.orderId = '',
    this.giftCardId = '',
    this.direction = '',
    this.status = 'completed',
    this.description = '',
    this.currency = 'LYD',
    this.balanceAfter = 0,
  });

  final String id;
  final String title;
  final double amount;
  final String type;
  final String customerId;
  final String orderId;
  final String giftCardId;
  final String direction;
  final String status;
  final String description;
  final String currency;
  final double balanceAfter;
  final DateTime createdAt;

  String get displayTitle => title.isNotEmpty ? title : description;
  bool get isCredit => (direction.isNotEmpty ? direction : type) == 'credit';

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final title = json['title'] as String? ?? '';
    final description = json['description'] as String? ?? title;
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: type,
      title: title,
      customerId: json['customerId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      giftCardId: json['giftCardId'] as String? ?? '',
      direction: json['direction'] as String? ?? type,
      status: json['status'] as String? ?? 'completed',
      description: description,
      currency: json['currency'] as String? ?? 'LYD',
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'type': type,
    'customerId': customerId,
    'orderId': orderId,
    'giftCardId': giftCardId,
    'direction': direction,
    'status': status,
    'description': description,
    'currency': currency,
    'balanceAfter': balanceAfter,
    'createdAt': createdAt.toIso8601String(),
  };
}

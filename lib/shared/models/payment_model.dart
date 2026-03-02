class PaymentModel {
  final int id;
  final int dolilId;
  final String amount;
  final String method;
  final String? reference;
  final String? notes;
  final String paidAt;
  final String createdAt;

  const PaymentModel({
    required this.id,
    required this.dolilId,
    required this.amount,
    required this.method,
    this.reference,
    this.notes,
    required this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] ?? 0,
    dolilId: json['dolil_id'] ?? 0,
    amount: (json['amount'] ?? 0).toString(),
    method: json['method'] ?? '',
    reference: json['reference'],
    notes: json['notes'],
    paidAt: json['paid_at'] ?? json['created_at'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}

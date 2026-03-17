class Client {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String address;
  final DateTime createdAt;
  final DateTime? lastContactDate;

  Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.address,
    required this.createdAt,
    this.lastContactDate,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastContactDate': lastContactDate?.toIso8601String(),
    };
  }

  // Create from Firestore data
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      company: map['company'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastContactDate: map['lastContactDate'] != null
          ? DateTime.parse(map['lastContactDate'] as String)
          : null,
    );
  }

  // Copy with method for updates
  Client copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? address,
    DateTime? createdAt,
    DateTime? lastContactDate,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastContactDate: lastContactDate ?? this.lastContactDate,
    );
  }
}

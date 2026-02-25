class Student {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String passwordHash;
  final DateTime createdAt;
  final String? profileImageUrl;
  final bool isActive;

  Student({
    String? id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.passwordHash,
    this.profileImageUrl,
    this.isActive = false,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'passwordHash': passwordHash,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      address: map['address'],
      phone: map['phone'],
      passwordHash: map['passwordHash'],
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? address,
    String? phone,
    String? passwordHash,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ScoreHistory {
  final String id;
  final String studentId;
  final String category;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;

  ScoreHistory({
    String? id,
    required this.studentId,
    required this.category,
    required this.score,
    required this.totalQuestions,
    DateTime? timestamp,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScoreHistory.fromMap(Map<String, dynamic> map) {
    return ScoreHistory(
      id: map['id'],
      studentId: map['studentId'],
      category: map['category'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  int get percentage => (score / totalQuestions * 100).round();
}

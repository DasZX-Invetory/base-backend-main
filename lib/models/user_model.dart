import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  int? id;
  String? tenantId; // UUID do tenant (empresa)
  String? tenantName; // Nome do tenant (empresa)
  String? name;
  String? email;
  String? password;
  String? avatarUrl;
  DateTime? birthDate;
  String? role; // 'owner', 'manager', 'technician'
  bool? active;
  DateTime? lastLogin;
  DateTime? createdAt;
  DateTime? deletedAt;

  UserModel({
    this.id,
    this.tenantId,
    this.tenantName,
    this.name,
    this.email,
    this.password,
    this.avatarUrl,
    this.birthDate,
    this.role,
    this.active,
    this.lastLogin,
    this.createdAt,
    this.deletedAt,
  });

  /// Converte para Map (usado para JSON de resposta da API)
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'birth_date': birthDate?.toIso8601String(),
      'role': role,
      'is_active': active,
    };
  }

  /// Cria UserModel a partir de um Map do banco PostgreSQL
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      tenantId: map['tenant_id']?.toString(),
      tenantName: map['tenant_name'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      password: map['password_hash'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      birthDate: _parseDateTime(map['birth_date']),
      role: map['role'] as String?,
      active: map['is_active'] == true || map['is_active'] == 1,
      lastLogin: _parseDateTime(map['last_login']),
      createdAt: _parseDateTime(map['created_at']),
      deletedAt: _parseDateTime(map['deleted_at']),
    );
  }

  /// Factory para buscar usuário pelo email (usado no login)
  factory UserModel.fromEmail(Map map) {
    return UserModel(
      id: map['id'] as int?,
      tenantId: map['tenant_id']?.toString(),
      tenantName: map['tenant_name'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      password: map['password_hash'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String?,
      active: map['is_active'] == true || map['is_active'] == 1,
    );
  }

  /// Factory para criar usuário a partir do request da API
  factory UserModel.fromRequest(Map map) {
    return UserModel(
      id: map['id'] as int?,
      tenantId: map['tenant_id']?.toString(),
      name: map['name'] as String?,
      email: map['email'] as String?,
      password: map['password'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      birthDate: _parseBirthDate(map['birth_date']),
      role: map['role'] as String? ?? 'technician',
      active: map['is_active'] ?? true,
    );
  }

  /// Retorna dados do usuário para resposta de login
  Map<String, dynamic> toLoginResponse() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'role': role,
      'avatar_url': avatarUrl,
      'is_active': active,
    };
  }

  Map toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'birth_date': birthDate?.toIso8601String(),
      'role': role,
      'is_active': active,
    };
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Helper para parsear DateTime do PostgreSQL
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Helper para parsear data de nascimento (aceita DD-MM-YYYY ou ISO)
  static DateTime? _parseBirthDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      // Tenta formato ISO primeiro
      var parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;

      // Tenta formato DD-MM-YYYY
      final parts = value.split('-');
      if (parts.length == 3) {
        try {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, tenantId: $tenantId, name: $name, email: $email, avatarUrl: $avatarUrl, birthDate: $birthDate, role: $role, active: $active)';
  }
}

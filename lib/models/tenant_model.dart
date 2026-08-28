// ignore_for_file: public_member_api_docs, sort_constructors_first
class TenantModel {
  String? id;
  String? name;
  String? document;
  String? emailContact;
  String? planType;
  bool? active;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  TenantModel({
    this.id,
    this.name,
    this.document,
    this.emailContact,
    this.planType,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'document': document,
      'email_contact': emailContact,
      'plan_type': planType,
      'is_active': active,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      document: map['document'] != null ? map['document'] as String : null,
      emailContact: map['email_contact'] != null
          ? map['email_contact'] as String
          : null,
      planType: map['plan_type'] != null ? map['plan_type'] as String : null,
      active: map['is_active'] != null ? map['is_active'] as bool : null,
      createdAt: map['created_at'] != null
          ? map['created_at'] as DateTime
          : null,
      updatedAt: map['updated_at'] != null
          ? map['updated_at'] as DateTime
          : null,
      deletedAt: map['deleted_at'] != null
          ? map['deleted_at'] as DateTime
          : null,
    );
  }

  factory TenantModel.fromRequest(Map map) {
    return TenantModel(
      id: map['id'] as String?,
      name: map['name'] as String?,
      document: map['document'] as String?,
      emailContact: map['email_contact'] as String?,
      planType: map['plan_type'] as String?,
      active: map['is_active'] ?? true,
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'document': document,
      'email_contact': emailContact,
      'plan_type': planType,
      'is_active': active,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TenantModel(id: $id, name: $name, document: $document, emailContact: $emailContact, planType: $planType, active: $active, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }
}

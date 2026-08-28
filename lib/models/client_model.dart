import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ClientModel {
  int? id;
  String? tenantId;
  String? name;
  String? document;
  String? phone;
  String? email;
  String? zipCode;
  String? address;
  String? city;
  String? state;
  String? notes;
  bool? active;
  DateTime? createdAt;
  DateTime? deletedAt;

  ClientModel({
    this.id,
    this.tenantId,
    this.name,
    this.document,
    this.phone,
    this.email,
    this.zipCode,
    this.address,
    this.city,
    this.state,
    this.notes,
    this.active,
    this.createdAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'document': document,
      'phone': phone,
      'email': email,
      'zipCode': zipCode,
      'address': address,
      'city': city,
      'state': state,
      'notes': notes,
      'active': active,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] != null ? map['id'] as int : null,
      tenantId: map['tenantId'] != null ? map['tenantId'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      document: map['document'] != null ? map['document'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      zipCode: map['zipCode'] != null ? map['zipCode'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      state: map['state'] != null ? map['state'] as String : null,
      notes: map['notes'] != null ? map['notes'] as String : null,
      active: map['active'] != null ? map['active'] as bool : null,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      deletedAt: map['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ClientModel.fromJson(String source) =>
      ClientModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

import '../../domain/entities/membro_escola.dart';

class MembroEscolaModel extends MembroEscola {
  const MembroEscolaModel({
    required super.id,
    required super.escolaId,
    required super.userId,
    super.email,
    required super.papel,
    required super.createdAt,
  });

  factory MembroEscolaModel.fromMap(Map<String, dynamic> map) {
    final createdRaw = map['created_at'] as String?;
    return MembroEscolaModel(
      id: map['id'] as String,
      escolaId: map['escola_id'] as String,
      userId: map['user_id'] as String,
      email: map['user_email'] as String?,
      papel: (map['papel'] as String?) ?? 'professor',
      createdAt: createdRaw != null && createdRaw.isNotEmpty
          ? DateTime.parse(createdRaw)
          : DateTime.now(),
    );
  }
}

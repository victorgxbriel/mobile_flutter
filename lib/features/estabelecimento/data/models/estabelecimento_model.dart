import 'package:json_annotation/json_annotation.dart';

part 'estabelecimento_model.g.dart';

@JsonSerializable()
class EstabelecimentoModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;
  final String cnpj;
  final String nomeFantasia;

  EstabelecimentoModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.cnpj,
    required this.nomeFantasia,
  });

  factory EstabelecimentoModel.fromJson(Map<String, dynamic> json) =>
      _$EstabelecimentoModelFromJson(json);

  Map<String, dynamic> toJson() => _$EstabelecimentoModelToJson(this);

  /// Formata o CNPJ para exibição (XX.XXX.XXX/XXXX-XX)
  String get cnpjFormatado {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }
}

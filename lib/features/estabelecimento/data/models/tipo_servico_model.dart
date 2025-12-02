import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tipo_servico_model.g.dart';

/// Enum dos tipos de serviço disponíveis
enum TipoServicoEnum {
  @JsonValue('ROTINA')
  rotina,
  @JsonValue('ESTETICA')
  estetica,
  @JsonValue('PROTECAO')
  protecao,
  @JsonValue('SANITIZACAO')
  sanitizacao,
}

@JsonSerializable()
class TipoServicoModel {
  final int id;
  final String slug;
  final String nome;
  final String? descricao;

  TipoServicoModel({
    required this.id,
    required this.slug,
    required this.nome,
    this.descricao,
  });

  factory TipoServicoModel.fromJson(Map<String, dynamic> json) =>
      _$TipoServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TipoServicoModelToJson(this);

  /// Retorna o enum correspondente ao slug
  TipoServicoEnum? get tipoEnum {
    return switch (slug) {
      'ROTINA' => TipoServicoEnum.rotina,
      'ESTETICA' => TipoServicoEnum.estetica,
      'PROTECAO' => TipoServicoEnum.protecao,
      'SANITIZACAO' => TipoServicoEnum.sanitizacao,
      _ => null,
    };
  }

  /// Retorna a cor associada ao tipo de serviço
  Color get cor {
    return switch (slug) {
      'ROTINA' => const Color(0xFF4CAF50),      // Verde - serviços do dia a dia
      'ESTETICA' => const Color(0xFF9C27B0),    // Roxo - beleza/estética
      'PROTECAO' => const Color(0xFF2196F3),    // Azul - proteção
      'SANITIZACAO' => const Color(0xFFFF9800), // Laranja - higienização
      _ => const Color(0xFF757575),             // Cinza - padrão
    };
  }

  /// Retorna o ícone associado ao tipo de serviço
  IconData get icone {
    return switch (slug) {
      'ROTINA' => Icons.local_car_wash,
      'ESTETICA' => Icons.auto_awesome,
      'PROTECAO' => Icons.shield,
      'SANITIZACAO' => Icons.cleaning_services,
      _ => Icons.car_repair,
    };
  }
}

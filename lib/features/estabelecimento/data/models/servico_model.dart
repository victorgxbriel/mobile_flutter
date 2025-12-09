import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'tipo_servico_model.dart';

part 'servico_model.g.dart';

@JsonSerializable()
class ServicoModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;
  final String titulo;
  final String? descricao;
  final String preco;
  final String tempoEstimado;
  final int? tipoServicoId;
  final int estabelecimentoId;
  
  /// Tipo de serviço incluído via ?includes=tipoServico
  final TipoServicoModel? tipoServico;

  ServicoModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.titulo,
    this.descricao,
    required this.preco,
    required this.tempoEstimado,
    this.tipoServicoId,
    required this.estabelecimentoId,
    this.tipoServico,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) =>
      _$ServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServicoModelToJson(this);

  /// Formata o preço para exibição (R$ XX,XX)
  String get precoFormatado {
    try {
      final valor = double.parse(preco);
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ $preco';
    }
  }

  /// Formata o tempo estimado para exibição
  String get tempoFormatado {
    try {
      final minutos = int.parse(tempoEstimado);
      if (minutos >= 60) {
        final horas = minutos ~/ 60;
        final mins = minutos % 60;
        if (mins == 0) {
          return '${horas}h';
        }
        return '${horas}h ${mins}min';
      }
      return '${minutos}min';
    } catch (e) {
      return tempoEstimado;
    }
  }

  /// Retorna o nome do tipo de serviço ou null
  String? get tipoServicoNome => tipoServico?.nome;

  /// Retorna a cor do tipo de serviço
  Color? get tipoServicoCor => tipoServico?.cor;

  /// Retorna o ícone do tipo de serviço
  IconData? get tipoServicoIcone => tipoServico?.icone;

  /// Factory para criar mock data para skeleton loading
  factory ServicoModel.skeleton() => ServicoModel(
    id: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    active: true,
    titulo: 'Serviço Exemplo',
    descricao: 'Descrição do serviço exemplo para skeleton',
    preco: '99.90',
    tempoEstimado: '60',
    tipoServicoId: null,
    estabelecimentoId: 0,
    tipoServico: null,
  );
}

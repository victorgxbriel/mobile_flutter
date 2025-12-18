import 'package:mobile_flutter/features/treatments/data/models/atendimento_model.dart';

sealed class AtendimentosState {
  const AtendimentosState();
}

final class AtendimentosInitial extends AtendimentosState {
  const AtendimentosInitial();
}

final class AtendimentosLoading extends AtendimentosState {
  const AtendimentosLoading();
}

final class AtendimentosLoaded extends AtendimentosState {
  final List<AtendimentoModel> atendimentos;

  const AtendimentosLoaded(this.atendimentos);
}

final class AtendimentosError extends AtendimentosState {
  final Object error;

  const AtendimentosError(this.error);
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../estabelecimento/data/models/servico_model.dart';
import '../../../../notifications/presentation/notifiers/notifications_notifier.dart';
import '../../../../vehicles/data/models/vehicle_model.dart';
import '../../../../vehicles/presentation/notifiers/vehicles_notifier.dart';
import '../../../../vehicles/presentation/state/vehicles_state.dart';
import '../../../data/models/slot_model.dart';
import '../notifiers/create_agendamento_notifier.dart';
import '../states/agendamento_state.dart';

class CreateAgendamentoPage extends StatefulWidget {
  final int estabelecimentoId;
  final String estabelecimentoNome;
  final List<ServicoModel> servicos;
  final int? servicoPreSelecionadoId;

  const CreateAgendamentoPage({
    super.key,
    required this.estabelecimentoId,
    required this.estabelecimentoNome,
    required this.servicos,
    this.servicoPreSelecionadoId,
  });

  @override
  State<CreateAgendamentoPage> createState() => _CreateAgendamentoPageState();
}

class _CreateAgendamentoPageState extends State<CreateAgendamentoPage> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Agendar inicialização para após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifiers();
    });
  }

  void _initializeNotifiers() {
    final notifier = context.read<CreateAgendamentoNotifier>();
    notifier.reset();
    notifier.setEstabelecimentoId(widget.estabelecimentoId);

    // Carregar as programações diárias (datas disponíveis)
    notifier.loadProgramacoes(widget.estabelecimentoId);

    // Se tiver um serviço pré-selecionado, adicionar
    if (widget.servicoPreSelecionadoId != null) {
      notifier.addServico(widget.servicoPreSelecionadoId!);
    }

    // Carregar veículos do cliente
    context.read<VehiclesNotifier>().loadVehicles();
  }

  void _onStepContinue() {
    final notifier = context.read<CreateAgendamentoNotifier>();

    // Validação por step
    if (_currentStep == 0 && notifier.selectedServicosIds.isEmpty) {
      _showError('Selecione pelo menos um serviço');
      return;
    }
    if (_currentStep == 1 && notifier.selectedCarroId == null) {
      _showError('Selecione um veículo');
      return;
    }
    if (_currentStep == 2 && notifier.selectedDate == null) {
      _showError('Selecione uma data');
      return;
    }
    if (_currentStep == 3 && notifier.selectedSlot == null) {
      _showError('Selecione um horário');
      return;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });

      // Quando avançar para o step de horário, carregar slots
      if (_currentStep == 3 && notifier.selectedDate != null) {
        notifier.loadSlots(widget.estabelecimentoId, notifier.selectedDate!);
      }
    } else {
      // Criar agendamento
      notifier.createAgendamento();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Agendamento'), centerTitle: true),
      body: Consumer<CreateAgendamentoNotifier>(
        builder: (context, notifier, child) {
          // Listener para sucesso na criação
          if (notifier.createState is CreateAgendamentoSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final state = notifier.createState as CreateAgendamentoSuccess;
              final agendamento = state.agendamento;
              final notificationsNotifier = context
                  .read<NotificationsNotifier>();
              String message =
                  'Seu agendamento em ${widget.estabelecimentoNome} foi confirmado.';

              final slot = agendamento.slot;
              final programacao = slot?.programacao;
              if (slot != null && programacao != null) {
                final dataFormatada = DateFormat(
                  'dd/MM/yyyy',
                ).format(programacao.dataAsDateTime);
                final horario = slot.horarioFormatado;
                message =
                    'Seu agendamento em ${widget.estabelecimentoNome} foi confirmado para $dataFormatada às $horario.';
              }
              notificationsNotifier.addNotification(
                title: 'Agendamento confirmado',
                message: message,
              );
              _showSuccessDialog();
            });
          } else if (notifier.createState is CreateAgendamentoError) {
            final error = notifier.createState as CreateAgendamentoError;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showError(error.message);
              notifier.resetCreateState();
            });
          }

          return Stepper(
            currentStep: _currentStep,
            onStepContinue: notifier.createState is CreateAgendamentoLoading
                ? null
                : _onStepContinue,
            onStepCancel: notifier.createState is CreateAgendamentoLoading
                ? null
                : _onStepCancel,
            controlsBuilder: (context, details) {
              final isLastStep = _currentStep == 4;
              final isLoading =
                  notifier.createState is CreateAgendamentoLoading;

              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: isLoading ? null : details.onStepContinue,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isLastStep ? 'Confirmar' : 'Continuar'),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: isLoading ? null : details.onStepCancel,
                        child: const Text('Voltar'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Serviços'),
                subtitle: notifier.selectedServicosIds.isEmpty
                    ? null
                    : Text(
                        '${notifier.selectedServicosIds.length} selecionado(s)',
                      ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                content: _buildServicosStep(notifier, colorScheme),
              ),
              Step(
                title: const Text('Veículo'),
                subtitle: notifier.selectedCarroId == null
                    ? null
                    : const Text('Selecionado'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
                content: _buildVeiculoStep(colorScheme),
              ),
              Step(
                title: const Text('Data'),
                subtitle: notifier.selectedDate == null
                    ? null
                    : Text(
                        DateFormat('dd/MM/yyyy').format(notifier.selectedDate!),
                      ),
                isActive: _currentStep >= 2,
                state: _currentStep > 2
                    ? StepState.complete
                    : StepState.indexed,
                content: _buildDataStep(notifier, colorScheme),
              ),
              Step(
                title: const Text('Horário'),
                subtitle: notifier.selectedSlot == null
                    ? null
                    : Text(notifier.selectedSlot!.slotTempo),
                isActive: _currentStep >= 3,
                state: _currentStep > 3
                    ? StepState.complete
                    : StepState.indexed,
                content: _buildHorarioStep(notifier, colorScheme),
              ),
              Step(
                title: const Text('Confirmação'),
                isActive: _currentStep >= 4,
                state: StepState.indexed,
                content: _buildConfirmacaoStep(notifier, colorScheme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServicosStep(
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    if (widget.servicos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Nenhum serviço disponível'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione os serviços desejados:',
          style: TextStyle(color: colorScheme.outline),
        ),
        const SizedBox(height: 12),
        ...widget.servicos.map((servico) {
          final isSelected = notifier.isServicoSelected(servico.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected ? colorScheme.primaryContainer : null,
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (_) => notifier.toggleServico(servico.id),
              title: Text(
                servico.titulo,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (servico.descricao != null)
                    Text(
                      servico.descricao!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        servico.precoFormatado,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        servico.tempoFormatado,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: servico.descricao != null,
            ),
          );
        }),
        if (notifier.selectedServicosIds.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTotalServicos(notifier, colorScheme),
        ],
      ],
    );
  }

  Widget _buildTotalServicos(
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final servicosSelecionados = widget.servicos
        .where((s) => notifier.selectedServicosIds.contains(s.id))
        .toList();

    double total = 0;
    for (final servico in servicosSelecionados) {
      try {
        total += double.parse(servico.preco);
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total estimado:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeiculoStep(ColorScheme colorScheme) {
    return Consumer2<VehiclesNotifier, CreateAgendamentoNotifier>(
      builder: (context, vehiclesNotifier, agendamentoNotifier, child) {
        final state = vehiclesNotifier.state;

        return switch (state) {
          VehiclesInitial() || VehiclesLoading() => _buildVehiclesSkeletonList(
            agendamentoNotifier,
            colorScheme,
          ),
          VehiclesError(message: final msg) => Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error),
                const SizedBox(height: 8),
                Text(msg),
                TextButton(
                  onPressed: () {
                    context.read<VehiclesNotifier>().loadVehicles();
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
          VehiclesLoaded(vehicles: final vehicles) =>
            vehicles.isEmpty
                ? _buildNoVehicles(colorScheme)
                : _buildVehiclesList(
                    vehicles,
                    agendamentoNotifier,
                    colorScheme,
                  ),
        };
      },
    );
  }

  Widget _buildNoVehicles(ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(
          Icons.directions_car_outlined,
          size: 64,
          color: colorScheme.outline,
        ),
        const SizedBox(height: 16),
        const Text('Você não possui veículos cadastrados'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _navigateToAddVehicle(),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Veículo'),
        ),
      ],
    );
  }

  Widget _buildVehiclesList(
    List<VehicleModel> vehicles,
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione o veículo:',
          style: TextStyle(color: colorScheme.outline),
        ),
        const SizedBox(height: 12),
        ...vehicles.map((vehicle) {
          final isSelected = notifier.selectedCarroId == vehicle.id;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected ? colorScheme.primaryContainer : null,
            child: RadioListTile<int>(
              value: vehicle.id,
              groupValue: notifier.selectedCarroId,
              onChanged: (value) {
                if (value != null) {
                  notifier.setSelectedCarro(value);
                }
              },
              title: Text(
                '${vehicle.marca} ${vehicle.modelo}',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                '${vehicle.placa} • ${vehicle.ano}',
                style: TextStyle(color: colorScheme.outline),
              ),
              secondary: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _navigateToAddVehicle(),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar novo veículo'),
        ),
      ],
    );
  }

  Widget _buildDataStep(
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final programacoesState = notifier.programacoesState;

    return switch (programacoesState) {
      ProgramacoesInitial() ||
      ProgramacoesLoading() => _buildDatasSkeletonList(colorScheme),
      ProgramacoesError(message: final msg) => Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(height: 8),
            Text(msg),
            TextButton(
              onPressed: () =>
                  notifier.loadProgramacoes(widget.estabelecimentoId),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
      ProgramacoesLoaded() => _buildCalendarWithAvailableDates(
        notifier,
        colorScheme,
      ),
    };
  }

  Widget _buildCalendarWithAvailableDates(
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final datasDisponiveis = notifier.datasDisponiveis;

    if (datasDisponiveis.isEmpty) {
      return Column(
        children: [
          Icon(Icons.event_busy, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          const Text(
            'Não há datas disponíveis para agendamento',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'O estabelecimento ainda não abriu agenda',
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      );
    }

    final today = DateTime.now();
    // Encontra a primeira e última data disponível
    final sortedDates = datasDisponiveis.toList()..sort();
    final firstAvailableDate = sortedDates.first;
    final lastAvailableDate = sortedDates.last;

    // Determina initial date - se selectedDate existe e é válida, usa ela;
    // senão, usa a primeira data disponível
    DateTime initialDate;
    if (notifier.selectedDate != null &&
        notifier.isDateAvailable(notifier.selectedDate!)) {
      initialDate = notifier.selectedDate!;
    } else if (firstAvailableDate.isAfter(today) ||
        _isSameDay(firstAvailableDate, today)) {
      initialDate = firstAvailableDate;
    } else {
      initialDate = today;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione a data do agendamento:',
          style: TextStyle(color: colorScheme.outline),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Apenas as datas com horários disponíveis podem ser selecionadas',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CalendarDatePicker(
          initialDate: initialDate,
          firstDate: today,
          lastDate: lastAvailableDate.add(const Duration(days: 1)),
          onDateChanged: (date) {
            if (notifier.isDateAvailable(date)) {
              notifier.setSelectedDate(date);
            } else {
              _showError('Esta data não possui horários disponíveis');
            }
          },
          selectableDayPredicate: (date) => notifier.isDateAvailable(date),
        ),
        if (notifier.selectedDate != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Data selecionada: ${DateFormat('dd/MM/yyyy').format(notifier.selectedDate!)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildHorarioStep(
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final state = notifier.slotsState;

    if (notifier.selectedDate == null) {
      return const Text('Selecione uma data primeiro');
    }

    return switch (state) {
      SlotsInitial() || SlotsLoading() => _buildSlotsSkeletonList(colorScheme),
      SlotsError(message: final msg) => Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(height: 8),
            Text(msg),
            TextButton(
              onPressed: () => notifier.loadSlots(
                widget.estabelecimentoId,
                notifier.selectedDate!,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
      SlotsLoaded(slots: final slots) =>
        slots.isEmpty
            ? _buildNoSlots(colorScheme)
            : _buildSlotsList(slots, notifier, colorScheme),
    };
  }

  Widget _buildNoSlots(ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(Icons.event_busy, size: 64, color: colorScheme.outline),
        const SizedBox(height: 16),
        const Text(
          'Não há horários disponíveis para esta data',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tente selecionar outra data',
          style: TextStyle(color: colorScheme.outline),
        ),
      ],
    );
  }

  Widget _buildSlotsList(
    List<SlotTempoModel> slots,
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final slotsDisponiveis = slots.where((s) => s.isDisponivel).toList();

    if (slotsDisponiveis.isEmpty) {
      return _buildNoSlots(colorScheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horários disponíveis:',
          style: TextStyle(color: colorScheme.outline),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slotsDisponiveis.map((slot) {
            final isSelected = notifier.selectedSlot?.id == slot.id;
            return ChoiceChip(
              label: Text(slot.slotTempo),
              selected: isSelected,
              onSelected: (_) => notifier.setSelectedSlot(slot),
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmacaoStep(
    CreateAgendamentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final servicosSelecionados = widget.servicos
        .where((s) => notifier.selectedServicosIds.contains(s.id))
        .toList();

    final vehiclesNotifier = context.read<VehiclesNotifier>();
    VehicleModel? vehicleSelecionado;
    if (vehiclesNotifier.state is VehiclesLoaded &&
        notifier.selectedCarroId != null) {
      final vehicles = (vehiclesNotifier.state as VehiclesLoaded).vehicles;
      vehicleSelecionado = vehicles
          .where((v) => v.id == notifier.selectedCarroId)
          .firstOrNull;
    }

    double total = 0;
    for (final servico in servicosSelecionados) {
      try {
        total += double.parse(servico.preco);
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirme os dados do agendamento:',
          style: TextStyle(color: colorScheme.outline),
        ),
        const SizedBox(height: 16),
        _buildConfirmationItem(
          icon: Icons.store,
          title: 'Estabelecimento',
          value: widget.estabelecimentoNome,
          colorScheme: colorScheme,
        ),
        _buildConfirmationItem(
          icon: Icons.car_repair,
          title: 'Serviços',
          value: servicosSelecionados.map((s) => s.titulo).join(', '),
          colorScheme: colorScheme,
        ),
        if (vehicleSelecionado != null)
          _buildConfirmationItem(
            icon: Icons.directions_car,
            title: 'Veículo',
            value:
                '${vehicleSelecionado.marca} ${vehicleSelecionado.modelo} - ${vehicleSelecionado.placa}',
            colorScheme: colorScheme,
          ),
        if (notifier.selectedDate != null)
          _buildConfirmationItem(
            icon: Icons.calendar_today,
            title: 'Data',
            value: DateFormat('dd/MM/yyyy').format(notifier.selectedDate!),
            colorScheme: colorScheme,
          ),
        if (notifier.selectedSlot != null)
          _buildConfirmationItem(
            icon: Icons.access_time,
            title: 'Horário',
            value: notifier.selectedSlot!.slotTempo,
            colorScheme: colorScheme,
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationItem({
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Agendamento Confirmado!'),
        content: const Text(
          'Seu agendamento foi realizado com sucesso. Você pode acompanhar o status na aba de agendamentos.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/appointments');
            },
            child: const Text('Ver Agendamentos'),
          ),
        ],
      ),
    );
  }

  /// Skeleton loading para lista de veículos usando mock data
  Widget _buildVehiclesSkeletonList(
    CreateAgendamentoNotifier agendamentoNotifier,
    ColorScheme colorScheme,
  ) {
    final mockVehicles = List.generate(3, (_) => VehicleModel.skeleton());

    return Skeletonizer(
      enabled: true,
      child: _buildVehiclesList(mockVehicles, agendamentoNotifier, colorScheme),
    );
  }

  /// Skeleton loading para lista de slots usando mock data
  Widget _buildSlotsSkeletonList(ColorScheme colorScheme) {
    final mockProgramacao = ProgramacaoDiariaModel.skeleton();

    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horários disponíveis:',
            style: TextStyle(color: colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Text(
            'Funcionamento: ${mockProgramacao.horaInicio} - ${mockProgramacao.horaTermino}',
            style: TextStyle(color: colorScheme.outline, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mockProgramacao.slots!.map((slot) {
              return ChoiceChip(
                label: Text(slot.slotTempo),
                selected: false,
                onSelected: null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Skeleton loading para calendário de datas usando shimmer simples
  Widget _buildDatasSkeletonList(ColorScheme colorScheme) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecione a data do agendamento:',
            style: TextStyle(color: colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Carregando datas disponíveis...',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Simula um calendário com grid de dias
          Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header do mês
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.chevron_left),
                    Text(
                      'Dezembro 2024',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 16),
                // Dias da semana
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                      .map(
                        (d) => Text(
                          d,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.outline,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Grid de dias (simulado)
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    itemCount: 35,
                    itemBuilder: (context, index) {
                      final day = index - 5; // Offset para começar no dia certo
                      if (day < 1 || day > 31) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          day.toString(),
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddVehicle() async {
    // 1. Navega para a rota FULL SCREEN (sem shell)
    await context.push('/common/vehicle/add');

    // 2. Quando o usuário voltar (pop), verificamos se o widget ainda existe
    if (!mounted) return;

    // 3. Recarregamos a lista de veículos para aparecer o novo
    context.read<VehiclesNotifier>().loadVehicles();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile_flutter/features/schedule/data/models/programacao_diaria_model.dart';
import 'package:mobile_flutter/features/schedule/presentation/notifiers/schedule_notifier.dart';
import 'package:mobile_flutter/features/schedule/presentation/states/schedule_state.dart';

class HomeEstablishmentPage extends StatelessWidget {
  final ScheduleNotifier notifier;

  const HomeEstablishmentPage({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notifier,
      child: const _HomeEstablishmentPage(),
    );
  }
}

class _HomeEstablishmentPage extends StatefulWidget {
  const _HomeEstablishmentPage();

  @override
  State<_HomeEstablishmentPage> createState() => _HomeEstablishmentPageState();
}

class _HomeEstablishmentPageState extends State<_HomeEstablishmentPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // Carregar programações ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleNotifier>().loadProgramacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programação Diária'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ScheduleNotifier>().refresh(),
          ),
        ],
      ),
      body: Consumer<ScheduleNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;

          if (state is ScheduleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notifier.refresh(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          // Mostrar skeleton também no estado inicial, pois ainda não há dados
          final isLoading =
              state is ScheduleLoading || state is ScheduleInitial;

          return Skeletonizer(
            enabled: isLoading,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalendar(context, notifier),
                  const Divider(),
                  isLoading
                      ? _buildSkeletonDetails(context)
                      : _buildSelectedDayDetails(context, notifier),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateScheduleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Programação'),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, ScheduleNotifier notifier) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: TableCalendar<ProgramacaoDiaria>(
        locale: 'pt_BR',
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: notifier.getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          notifier.selectDate(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetails(
    BuildContext context,
    ScheduleNotifier notifier,
  ) {
    if (_selectedDay == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Selecione um dia no calendário'),
      );
    }

    final programacoes = notifier.selectedProgramacoes;

    if (programacoes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhuma programação para ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Crie uma nova programação para este dia'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Programações de ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${programacoes.length}'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...programacoes.map(
            (prog) => _buildProgramacaoCard(context, notifier, prog),
          ),
        ],
      ),
    );
  }

  /// Skeleton placeholder for loading state
  Widget _buildSkeletonDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Programações de ${DateFormat('dd/MM/yyyy').format(_selectedDay ?? DateTime.now())}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              Chip(
                label: const Text('2'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mock programação cards for skeleton
          _buildSkeletonProgramacaoCard(context),
          _buildSkeletonProgramacaoCard(context),
        ],
      ),
    );
  }

  Widget _buildSkeletonProgramacaoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.schedule, color: theme.colorScheme.primary),
        title: const Text('08:00 - 18:00'),
        subtitle: const Text('Intervalo: 30 min • 20 slots'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: null,
              tooltip: 'Excluir',
            ),
            Icon(Icons.expand_more, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramacaoCard(
    BuildContext context,
    ScheduleNotifier notifier,
    ProgramacaoDiaria programacao,
  ) {
    final isExpanded = notifier.isExpanded(programacao);
    final slots = notifier.getSlotsForProgramacao(programacao.id);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isExpanded ? 4 : 1,
      child: ExpansionTile(
        key: Key('prog_${programacao.id}'),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (_) => notifier.toggleExpanded(programacao),
        leading: Icon(Icons.schedule, color: theme.colorScheme.primary),
        title: Text(
          '${programacao.horaInicio.substring(0, 5)} - ${programacao.horaTermino.substring(0, 5)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Intervalo: ${_formatInterval(programacao.intervaloHorario)} • ${slots.length} slots',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () =>
                  _confirmDelete(context, notifier, programacao.id),
              tooltip: 'Excluir',
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Agendamentos por horário:',
                  '${programacao.agendamentosPorHorario}',
                ),
                const SizedBox(height: 12),
                Text(
                  'Slots de Horário',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (slots.isEmpty)
                  const Text('Nenhum slot disponível')
                else
                  _buildSlotsGrid(context, notifier, programacao.id, slots),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatInterval(String interval) {
    // Converte 00:30:00 para "30 min" ou 01:00:00 para "1h"
    final parts = interval.split(':');
    if (parts.length >= 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      if (hours > 0 && minutes > 0) {
        return '${hours}h${minutes}min';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '$minutes min';
      }
    }
    return interval;
  }

  Widget _buildSlotsGrid(
    BuildContext context,
    ScheduleNotifier notifier,
    int programacaoId,
    List<SlotTempo> slots,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isDisponivel = slot.disponivel ?? false;
        return FilterChip(
          label: Text(
            slot.slotTempo.substring(0, 5),
            style: TextStyle(
              color: isDisponivel ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isDisponivel,
          selectedColor: Colors.green.shade100,
          backgroundColor: Colors.red.shade100,
          checkmarkColor: Colors.green.shade800,
          onSelected: (_) => notifier.toggleSlot(programacaoId, slot.id),
          avatar: Icon(
            isDisponivel ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: isDisponivel ? Colors.green.shade800 : Colors.red.shade800,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _showCreateScheduleDialog(BuildContext context) async {
    final notifier = context.read<ScheduleNotifier>();
    final horaInicioController = TextEditingController(text: '08:00');
    final horaTerminoController = TextEditingController(text: '18:00');
    final agendamentosController = TextEditingController(text: '1');

    // Opções de intervalo no formato ISO 8601 Duration
    const intervalOptions = <String, String>{
      'PT15M': '15 minutos',
      'PT30M': '30 minutos',
      'PT45M': '45 minutos',
      'PT1H': '1 hora',
      'PT1H30M': '1 hora e 30 minutos',
      'PT2H': '2 horas',
    };

    String selectedInterval = 'PT30M'; // valor padrão

    return showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova Programação'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDay ?? DateTime.now())}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: horaInicioController,
                      decoration: const InputDecoration(
                        labelText: 'Hora Início (HH:mm)',
                        hintText: '08:00',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: horaTerminoController,
                      decoration: const InputDecoration(
                        labelText: 'Hora Término (HH:mm)',
                        hintText: '18:00',
                        prefixIcon: Icon(Icons.access_time_filled),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedInterval,
                      decoration: const InputDecoration(
                        labelText: 'Intervalo entre horários',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      items: intervalOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedInterval = value ?? 'PT30M';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: agendamentosController,
                      decoration: const InputDecoration(
                        labelText: 'Agendamentos por Horário',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await notifier.createProgramacao(
                      data: _selectedDay ?? DateTime.now(),
                      horaInicio: horaInicioController.text,
                      horaTermino: horaTerminoController.text,
                      intervaloHorario: selectedInterval,
                      agendamentosPorHorario:
                          int.tryParse(agendamentosController.text) ?? 1,
                    );

                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Programação criada com sucesso!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao criar programação'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ScheduleNotifier notifier,
    int programacaoId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Deseja realmente excluir esta programação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await notifier.removeProgramacao(programacaoId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Programação excluída com sucesso!'
                  : 'Erro ao excluir programação',
            ),
            backgroundColor: success ? null : Colors.red,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/features/treatments/data/models/atendimento_model.dart';
import 'package:mobile_flutter/features/treatments/presentation/notifiers/atendimentos_notifier.dart';
import 'package:mobile_flutter/features/treatments/presentation/states/atendimentos_state.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/data_widget.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mobile_flutter/widgets/error_view.dart';

class TreatmentsPage extends StatefulWidget {
  const TreatmentsPage({super.key});

  @override
  State<TreatmentsPage> createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends State<TreatmentsPage> {
  @override
  void initState() {
    super.initState();
    // Agendar o carregamento para após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAtendimentos();
    });
  }

  void _loadAtendimentos() {
    context.read<AtendimentosNotifier>().loadAtendimentos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AtendimentosNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          appBar: DataWidget(
            previousDay: () {
              notifier.previousDay();
            },
            nextDay: () {
              notifier.nextDay();
            },
            date: notifier.selectedDate,
            onTodayPressed: () {
              notifier.goToToday();
            },
            onCalendarPressed: () =>
                _showDatePickerBottomSheet(context, notifier),
          ),
          body: _buildBody(notifier, colorScheme),
        );
      },
    );
  }

  void _showDatePickerBottomSheet(
    BuildContext context,
    AtendimentosNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Selecionar Data', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              CalendarDatePicker(
                initialDate: notifier.selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                onDateChanged: (date) {
                  notifier.setDate(date);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(AtendimentosNotifier notifier, ColorScheme colorScheme) {
    final state = notifier.state;

    // AnimatedSwitcher para animar a transição quando a data muda
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        // Slide horizontal + fade
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _buildBodyContent(state, notifier, colorScheme),
    );
  }

  Widget _buildBodyContent(
    AtendimentosState state,
    AtendimentosNotifier notifier,
    ColorScheme colorScheme,
  ) {
    // Key única baseada na data para forçar a animação
    final key = ValueKey(notifier.selectedDate.toString().split(' ')[0]);

    return switch (state) {
      AtendimentosInitial() || AtendimentosLoading() => _buildSkeletonList(),
      AtendimentosError(error: final err) => ErrorView(
        key: key,
        error: err,
        onRetry: _loadAtendimentos,
      ),
      AtendimentosLoaded() =>
        notifier.atendimentosFiltrados.isEmpty
            ? _buildEmptyState(colorScheme, notifier.selectedDate, key)
            : _buildAtendimentosList(
                notifier.atendimentosFiltrados,
                colorScheme,
                key,
              ),
    };
  }

  Widget _buildEmptyState(
    ColorScheme colorScheme,
    DateTime selectedDate,
    Key key,
  ) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 80, color: colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              'Nenhum atendimento',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há atendimentos para $dateFormatted.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtendimentosList(
    List<AtendimentoModel> atendimentos,
    ColorScheme colorScheme,
    Key key,
  ) {
    return RefreshIndicator(
      key: key,
      onRefresh: () async => _loadAtendimentos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: atendimentos.length,
        itemBuilder: (context, index) {
          final atendimento = atendimentos[index];
          return _buildAtendimentoCard(atendimento, colorScheme);
        },
      ),
    );
  }

  Widget _buildAtendimentoCard(
    AtendimentoModel atendimento,
    ColorScheme colorScheme,
  ) {
    final statusColor = _getStatusColor(atendimento.situacaoId, colorScheme);
    final statusIcon = _getStatusIcon(atendimento.situacaoId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navegar para detalhes do atendimento
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atendimento #${atendimento.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            atendimento.situacaoLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (atendimento.valorTotal != null)
                    Text(
                      atendimento.valorTotalFormatado,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    'Criado em ${DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(atendimento.createdAt)}',
                    style: TextStyle(color: colorScheme.outline, fontSize: 13),
                  ),
                ],
              ),
              if (atendimento.horaInicio != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Início: ${DateFormat('HH:mm', 'pt_BR').format(atendimento.horaInicio!)}',
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
              if (atendimento.servicos != null &&
                  atendimento.servicos!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.cleaning_services_outlined,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${atendimento.servicos!.length} serviço(s)',
                        style: TextStyle(
                          color: colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int situacaoId, ColorScheme colorScheme) {
    return switch (situacaoId) {
      1 => Colors.orange, // Aguardando
      2 => Colors.blue, // Em Andamento
      3 => Colors.green, // Concluído
      4 => colorScheme.error, // Cancelado
      _ => colorScheme.outline,
    };
  }

  IconData _getStatusIcon(int situacaoId) {
    return switch (situacaoId) {
      1 => Icons.hourglass_empty, // Aguardando
      2 => Icons.engineering, // Em Andamento
      3 => Icons.check_circle_outline, // Concluído
      4 => Icons.cancel_outlined, // Cancelado
      _ => Icons.help_outline,
    };
  }

  /// Skeleton loading usando mock data - layout sempre sincronizado
  Widget _buildSkeletonList() {
    final colorScheme = Theme.of(context).colorScheme;
    final mockList = List.generate(4, (_) => AtendimentoModel.skeleton());

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockList.length,
        itemBuilder: (context, index) =>
            _buildAtendimentoCard(mockList[index], colorScheme),
      ),
    );
  }
}

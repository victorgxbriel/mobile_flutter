import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../data/models/servico_model.dart';
import '../notifiers/servicos_notifier.dart';
import '../states/servico_state.dart';

class ServicesPage extends StatelessWidget {
  final ServicosNotifier notifier;

  const ServicesPage({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notifier,
      child: const _ServicesPage(),
    );
  }
}

class _ServicesPage extends StatefulWidget {
  const _ServicesPage();

  @override
  State<_ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<_ServicesPage> {
  late bool isFuncionario = context.read<ServicosNotifier>().isFuncionario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicosNotifier>().loadServicos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Meus Serviços'),
      ),
      floatingActionButton: !isFuncionario
          ? FloatingActionButton.extended(
              heroTag: 'services_fab',
              onPressed: () => context.push('/establishment/profile/servicos/add'),
              icon: const Icon(Icons.add),
              label: const Text('Novo Serviço'),
            )
          : null,
      body: Consumer<ServicosNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;
          return switch (state) {
            ServicosInitial() || ServicosLoading() => _buildLoadingState(),
            ServicosLoaded(:final servicos) => _buildLoadedState(servicos),
            ServicosError(:final error) => _buildErrorState(error),
          };
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    final skeletonServicos = List.generate(5, (_) => ServicoModel.skeleton());
    return Skeletonizer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skeletonServicos.length,
        itemBuilder: (context, index) {
          return _ServicoCard(servico: skeletonServicos[index]);
        },
      ),
    );
  }

  Widget _buildLoadedState(List<ServicoModel> servicos) {
    if (servicos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.design_services_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum serviço cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (!isFuncionario) ...[
              const SizedBox(height: 8),
              Text(
                'Adicione um novo serviço para começar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ServicosNotifier>().loadServicos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: servicos.length,
        itemBuilder: (context, index) {
          return _ServicoCard(
            servico: servicos[index],
            onTap: () => _showServicoDetails(servicos[index]),
            onEdit: !isFuncionario
                ? () => context.push(
                      '/establishment/profile/servicos/${servicos[index].id}/edit',
                      extra: servicos[index],
                    )
                : null,
            onDelete: !isFuncionario ? () => _confirmDelete(servicos[index]) : null,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar serviços',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<ServicosNotifier>().loadServicos(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  void _showServicoDetails(ServicoModel servico) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    servico.titulo,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Chip(
                  label: Text(servico.active ? 'Ativo' : 'Inativo'),
                  backgroundColor: servico.active
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.errorContainer,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (servico.descricao != null) ...[
              Text(
                'Descrição',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                servico.descricao!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preço',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servico.precoFormatado,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duração',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servico.duracaoFormatada,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ServicoModel servico) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover serviço'),
        content: Text(
          'Deseja realmente remover o serviço "${servico.titulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ServicosNotifier>().deleteServico(servico.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço removido com sucesso')),
        );
      }
    }
  }
}

class _ServicoCard extends StatelessWidget {
  final ServicoModel servico;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ServicoCard({
    required this.servico,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      servico.titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (onEdit != null && onDelete != null)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: onEdit,
                          child: const Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: onDelete,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remover',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (servico.descricao != null) ...[
                const SizedBox(height: 8),
                Text(
                  servico.descricao!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    servico.precoFormatado,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    servico.duracaoFormatada,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

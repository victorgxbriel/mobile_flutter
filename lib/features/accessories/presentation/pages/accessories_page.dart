import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../data/models/acessorio_model.dart';
import '../notifiers/acessorios_notifier.dart';
import '../states/acessorio_state.dart';

class AccessoriesPage extends StatelessWidget {
  final AcessoriosNotifier notifier;

  const AccessoriesPage({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notifier,
      child: const _AccessoriesPage(),
    );
  }
}

class _AccessoriesPage extends StatefulWidget {
  const _AccessoriesPage();

  @override
  State<_AccessoriesPage> createState() => _AccessoriesPageState();
}

class _AccessoriesPageState extends State<_AccessoriesPage> {
  late bool isFuncionario = context.read<AcessoriosNotifier>().isFuncionario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcessoriosNotifier>().loadAcessorios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Meus Acessórios'),
      ),
      floatingActionButton: !isFuncionario
        ? FloatingActionButton.extended(
            heroTag: 'accessories_fab',
            onPressed: () => context.push('/establishment/profile/acessorios/add'),
            icon: const Icon(Icons.add),
            label: const Text('Novo Acessório'),
          )
        : null,
      body: Consumer<AcessoriosNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.value;
          return switch (state) {
            AcessoriosInitial() || AcessoriosLoading() => _buildLoadingState(),
            AcessoriosLoaded(:final acessorios) => _buildLoadedState(acessorios),
            AcessoriosError(:final error) => _buildErrorState(error),
          };
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    final skeletonAcessorios = List.generate(5, (_) => AcessorioModel.skeleton());
    return Skeletonizer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skeletonAcessorios.length,
        itemBuilder: (context, index) {
          return _AcessorioCard(acessorio: skeletonAcessorios[index]);
        },
      ),
    );
  }

  Widget _buildLoadedState(List<AcessorioModel> acessorios) {
    if (acessorios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum acessório cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if(!isFuncionario) ...[
              const SizedBox(height: 8),
              Text(
                'Adicione um novo acessório para começar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ]
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AcessoriosNotifier>().loadAcessorios(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acessorios.length,
        itemBuilder: (context, index) {
          return _AcessorioCard(
            acessorio: acessorios[index],
            onTap: () => _showAcessorioDetails(acessorios[index]),
            onEdit: !isFuncionario
              ? () => context.push(
                        '/establishment/profile/acessorios/${acessorios[index].id}/edit',
                        extra: acessorios[index],
                      )
            : null,
            onDelete: !isFuncionario ?  () => _confirmDelete(acessorios[index]) : null,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
            'Erro ao carregar acessórios',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<AcessoriosNotifier>().loadAcessorios(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  void _showAcessorioDetails(AcessorioModel acessorio) {
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
                    acessorio.titulo,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Chip(
                  label: Text(acessorio.active ? 'Ativo' : 'Inativo'),
                  backgroundColor: acessorio.active
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.errorContainer,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (acessorio.descricao != null) ...[
              Text(
                'Descrição',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                acessorio.descricao!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Preço',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              acessorio.precoFormatado,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AcessorioModel acessorio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover acessório'),
        content: Text(
          'Deseja realmente remover o acessório "${acessorio.titulo}"?',
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
      await context.read<AcessoriosNotifier>().deleteAcessorio(acessorio.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acessório removido com sucesso')),
        );
      }
    }
  }
}

class _AcessorioCard extends StatelessWidget {
  final AcessorioModel acessorio;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AcessorioCard({
    required this.acessorio,
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
                      acessorio.titulo,
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
              if (acessorio.descricao != null) ...[
                const SizedBox(height: 8),
                Text(
                  acessorio.descricao!,
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
                    acessorio.precoFormatado,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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

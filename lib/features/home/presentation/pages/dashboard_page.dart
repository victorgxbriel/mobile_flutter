import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/models/estabelecimento_models.dart';
import '../notifiers/home_notifier.dart';
import '../states/home_state.dart';
import '../widgets/estabelecimento_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeNotifier(ServiceLocator().estabelecimentoRepository)
        ..loadEstabelecimentos(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  final SearchController _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estabelecimentos'),
        centerTitle: true,
        actions: <Widget>[
          Consumer<HomeNotifier>(
            builder: (context, notifier, child) {
              return SearchAnchor(
                searchController: _searchController,
                builder: (context, controller) {
                  return IconButton(
                    onPressed: () => controller.openView(),
                    icon: const Icon(Symbols.search),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final query = controller.text.toLowerCase();
                  final estabelecimentos = notifier.estabelecimentos;

                  if (query.isEmpty) {
                    // Mostra todos quando não há pesquisa
                    return estabelecimentos.map((est) => _buildSearchTile(est, controller));
                  }

                  // Filtra por nome fantasia ou CNPJ
                  final filtered = estabelecimentos.where((est) {
                    return est.nomeFantasia.toLowerCase().contains(query) ||
                        est.cnpj.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return [
                      const ListTile(
                        leading: Icon(Icons.search_off),
                        title: Text('Nenhum estabelecimento encontrado'),
                      ),
                    ];
                  }

                  return filtered.map((est) => _buildSearchTile(est, controller));
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<HomeNotifier>(
        builder: (context, notifier, child) {
          return switch (notifier.state) {
            HomeInitial() || HomeLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            HomeError(message: final msg) => _buildErrorState(context, msg, notifier),
            HomeLoaded(estabelecimentos: final list) => list.isEmpty
                ? _buildEmptyState(context, notifier)
                : _buildEstabelecimentosList(context, list, notifier),
          };
        },
      ),
    );
  }

  Widget _buildSearchTile(EstabelecimentoModel est, SearchController controller) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.local_car_wash,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(est.nomeFantasia),
      subtitle: Text(est.cnpjFormatado),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: est.active ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          est.active ? 'Aberto' : 'Fechado',
          style: TextStyle(
            fontSize: 12,
            color: est.active ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ),
      onTap: () {
        controller.closeView(est.nomeFantasia);
        // Navegar para detalhes do estabelecimento
        _navigateToDetails(est);
      },
    );
  }

  void _navigateToDetails(EstabelecimentoModel estabelecimento) {
    context.push('/estabelecimento/${estabelecimento.id}');
  }

  Widget _buildErrorState(BuildContext context, String message, HomeNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.loadEstabelecimentos(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeNotifier notifier) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_car_wash_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text( 'Nenhum estabelecimento encontrado',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text( 'Puxe para atualizar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstabelecimentosList(
    BuildContext context,
    List estabelecimentos,
    HomeNotifier notifier,
  ) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: estabelecimentos.length,
        itemBuilder: (context, index) {
          final estabelecimento = estabelecimentos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EstabelecimentoCard(
              estabelecimento: estabelecimento,
              onTap: () => _navigateToDetails(estabelecimento),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/colors.dart';
import '../../data/models/estabelecimento_model.dart';
import '../../data/models/servico_model.dart';
import '../notifiers/estabelecimento_details_notifier.dart';
import '../states/estabelecimento_details_state.dart';

class EstabelecimentoDetailsPage extends StatefulWidget {
  final int estabelecimentoId;

  const EstabelecimentoDetailsPage({
    super.key,
    required this.estabelecimentoId,
  });

  @override
  State<EstabelecimentoDetailsPage> createState() =>
      _EstabelecimentoDetailsPageState();
}

class _EstabelecimentoDetailsPageState extends State<EstabelecimentoDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EstabelecimentoDetailsNotifier>()
          .loadDetails(widget.estabelecimentoId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EstabelecimentoDetailsNotifier>(
        builder: (context, notifier, child) {
          return switch (notifier.state) {
            EstabelecimentoDetailsInitial() ||
            EstabelecimentoDetailsLoading() =>
              const Center(child: CircularProgressIndicator()),
            EstabelecimentoDetailsLoaded(
              estabelecimento: final estabelecimento,
              servicos: final servicos
            ) =>
              _buildContent(estabelecimento, servicos),
            EstabelecimentoDetailsError(message: final message) =>
              _buildError(message),
          };
        },
      ),
    );
  }

  Widget _buildContent(
    EstabelecimentoModel estabelecimento,
    List<ServicoModel> servicos,
  ) {
    return RefreshIndicator(
      onRefresh: () => context
          .read<EstabelecimentoDetailsNotifier>()
          .refresh(widget.estabelecimentoId),
      child: CustomScrollView(
        slivers: [
          // AppBar com foto (1/3 da tela)
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height / 3,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.darkBlue,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageSlider(estabelecimento),
            ),
          ),

          // Conteúdo (2/3 da tela)
          SliverToBoxAdapter(
            child: _buildInfoSection(estabelecimento),
          ),

          // Header dos Serviços
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(
                    Icons.local_car_wash,
                    color: AppColors.darkBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Serviços disponíveis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${servicos.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de Serviços
          servicos.isEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptyServices(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildServiceCard(servicos[index]),
                      childCount: servicos.length,
                    ),
                  ),
                ),

          // Espaçamento inferior
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildImageSlider(EstabelecimentoModel estabelecimento) {
    // Por enquanto, apenas placeholder de imagem
    // Futuramente: PageView com fotos e mapa
    final items = [
      _buildImagePlaceholder(estabelecimento),
      // Futuramente adicionar mais fotos e mapa aqui
    ];

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: items.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemBuilder: (context, index) => items[index],
        ),
        // Indicador de página (quando houver mais de uma)
        if (items.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(EstabelecimentoModel estabelecimento) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.mediumBlue,
            AppColors.darkBlue,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_car_wash,
                size: 64,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              estabelecimento.nomeFantasia,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(EstabelecimentoModel estabelecimento) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do estabelecimento
          Text(
            estabelecimento.nomeFantasia,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // CNPJ
          Row(
            children: [
              Icon(
                Icons.business,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'CNPJ: ${estabelecimento.cnpjFormatado}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Status
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: estabelecimento.active ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                estabelecimento.active ? 'Aberto' : 'Fechado',
                style: TextStyle(
                  color: estabelecimento.active ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServicoModel servico) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Futuramente: agendar serviço
          _showServiceDetails(servico);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone do serviço (baseado no tipo)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (servico.tipoServicoCor ?? AppColors.lightBlue)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  servico.tipoServicoIcone ?? Icons.car_repair,
                  color: servico.tipoServicoCor ?? AppColors.darkBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Informações do serviço
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag do tipo de serviço
                    if (servico.tipoServico != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: servico.tipoServicoCor?.withValues(alpha: 0.15) ??
                              AppColors.mediumBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          servico.tipoServicoNome ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: servico.tipoServicoCor ?? AppColors.darkBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      servico.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (servico.descricao != null &&
                        servico.descricao!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        servico.descricao!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Tempo estimado
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          servico.tempoFormatado,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Preço
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    servico.precoFormatado,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyServices() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum serviço disponível',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este estabelecimento ainda não cadastrou serviços.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(ServicoModel servico) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (servico.tipoServicoCor ?? AppColors.lightBlue)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    servico.tipoServicoIcone ?? Icons.car_repair,
                    color: servico.tipoServicoCor ?? AppColors.darkBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (servico.tipoServico != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: servico.tipoServicoCor?.withValues(alpha: 0.15) ??
                                AppColors.mediumBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            servico.tipoServicoNome ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: servico.tipoServicoCor ?? AppColors.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        servico.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        servico.precoFormatado,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (servico.descricao != null && servico.descricao!.isNotEmpty) ...[
              const Text(
                'Descrição',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                servico.descricao!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Tempo estimado: ${servico.tempoFormatado}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implementar agendamento
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agendamento será implementado em breve!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Agendar serviço',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<EstabelecimentoDetailsNotifier>()
                  .loadDetails(widget.estabelecimentoId),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

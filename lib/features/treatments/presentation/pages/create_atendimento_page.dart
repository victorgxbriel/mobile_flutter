import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/cliente_model.dart';
import '../notifiers/create_atendimento_notifier.dart';
import '../states/create_atendimento_state.dart';

class CreateAtendimentoPage extends StatefulWidget {
  const CreateAtendimentoPage({super.key});

  @override
  State<CreateAtendimentoPage> createState() => _CreateAtendimentoPageState();
}

class _CreateAtendimentoPageState extends State<CreateAtendimentoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateAtendimentoNotifier>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<CreateAtendimentoNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Novo Atendimento'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
          ),
          body: _buildBody(notifier, colorScheme),
          bottomNavigationBar: _buildBottomBar(notifier, colorScheme),
        );
      },
    );
  }

  Widget _buildBody(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final state = notifier.state;

    if (state is CreateAtendimentoLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CreateAtendimentoError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: TextStyle(color: colorScheme.error),
            ),
            const SizedBox(height: 16),
            if (state.canRetry)
              ElevatedButton.icon(
                onPressed: () => notifier.loadData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
          ],
        ),
      );
    }

    if (state is CreateAtendimentoSubmitting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Criando atendimento...'),
          ],
        ),
      );
    }

    if (state is CreateAtendimentoSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Atendimento #${state.atendimento.id} criado!'),
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
        // Reseta o formulário para permitir criar outro atendimento
        notifier.reset();
      });
      // Mostra loading enquanto processa o callback
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildClienteSection(notifier, colorScheme),
          const SizedBox(height: 16),
          _buildCarroSection(notifier, colorScheme),
          const SizedBox(height: 16),
          _buildServicosSection(notifier, colorScheme),
          const SizedBox(height: 16),
          _buildAcessoriosSection(notifier, colorScheme),
          const SizedBox(height: 16),
          _buildResumoSection(notifier, colorScheme),
          const SizedBox(height: 80), // espaço para o bottom bar
        ],
      ),
    );
  }

  Widget _buildClienteSection(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Cliente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (notifier.selectedCliente != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => notifier.clearCliente(),
                    tooltip: 'Limpar',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (notifier.selectedCliente == null)
              _buildClienteSelector(notifier, colorScheme)
            else
              _buildSelectedCliente(notifier.selectedCliente!, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteSelector(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () => _showClienteBottomSheet(notifier),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: colorScheme.outline),
            const SizedBox(width: 12),
            Text(
              'Selecionar cliente...',
              style: TextStyle(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCliente(ClienteModel cliente, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            child: Text(
              cliente.nomeExibicao.substring(0, 1).toUpperCase(),
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nomeExibicao,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (cliente.cpfFormatado.isNotEmpty)
                  Text(
                    cliente.cpfFormatado,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: colorScheme.primary),
        ],
      ),
    );
  }

  void _showClienteBottomSheet(CreateAtendimentoNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Selecionar Cliente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: notifier.clientes.length,
                itemBuilder: (ctx, index) {
                  final cliente = notifier.clientes[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        cliente.nomeExibicao.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Text(cliente.nomeExibicao),
                    subtitle: cliente.cpfFormatado.isNotEmpty
                        ? Text(cliente.cpfFormatado)
                        : null,
                    onTap: () {
                      notifier.selectCliente(cliente);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarroSection(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final hasCliente = notifier.selectedCliente != null;
    final hasCarros = notifier.carrosDoCliente.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: hasCliente ? colorScheme.primary : colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  'Veículo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: hasCliente
                        ? colorScheme.onSurface
                        : colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasCliente)
              Text(
                'Selecione um cliente primeiro',
                style: TextStyle(color: colorScheme.outline),
              )
            else if (!hasCarros)
              Text(
                'Cliente não possui veículos cadastrados',
                style: TextStyle(color: colorScheme.error),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: notifier.carrosDoCliente.map((carro) {
                  final isSelected = notifier.selectedCarro?.id == carro.id;
                  return ChoiceChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(carro.nomeCompleto),
                        if (carro.placa != null)
                          Text(
                            carro.placa!,
                            style: const TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => notifier.selectCarro(carro),
                    avatar: Icon(
                      Icons.directions_car,
                      size: 18,
                      color: isSelected ? colorScheme.onPrimary : null,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicosSection(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Serviços',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showServicosBottomSheet(notifier),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            if (notifier.selectedServicos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhum serviço selecionado',
                  style: TextStyle(color: colorScheme.outline),
                ),
              )
            else
              ...notifier.selectedServicos.map(
                (servico) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle),
                  title: Text(servico.titulo),
                  subtitle: Text(servico.duracaoFormatada),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        servico.precoFormatado,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => notifier.removeServico(servico),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showServicosBottomSheet(CreateAtendimentoNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Adicionar Serviço',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: notifier.servicos.length,
                itemBuilder: (ctx, index) {
                  final servico = notifier.servicos[index];
                  final isSelected = notifier.isServicoSelected(servico);
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(servico.titulo),
                    subtitle: Text(servico.duracaoFormatada),
                    trailing: Text(
                      servico.precoFormatado,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      if (isSelected) {
                        notifier.removeServico(servico);
                      } else {
                        notifier.addServico(servico);
                      }
                      // Atualiza a UI do bottom sheet
                      (ctx as Element).markNeedsBuild();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Concluir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcessoriosSection(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Acessórios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(opcional)',
                  style: TextStyle(fontSize: 14, color: colorScheme.outline),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAcessoriosBottomSheet(notifier),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            if (notifier.selectedAcessorios.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhum acessório selecionado',
                  style: TextStyle(color: colorScheme.outline),
                ),
              )
            else
              ...notifier.selectedAcessorios.map(
                (acessorio) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle),
                  title: Text(acessorio.titulo),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        acessorio.precoFormatado,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => notifier.removeAcessorio(acessorio),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAcessoriosBottomSheet(CreateAtendimentoNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Adicionar Acessório',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: notifier.acessorios.length,
                itemBuilder: (ctx, index) {
                  final acessorio = notifier.acessorios[index];
                  final isSelected = notifier.isAcessorioSelected(acessorio);
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(acessorio.titulo),
                    trailing: Text(
                      acessorio.precoFormatado,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      if (isSelected) {
                        notifier.removeAcessorio(acessorio);
                      } else {
                        notifier.addAcessorio(acessorio);
                      }
                      (ctx as Element).markNeedsBuild();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Concluir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoSection(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return Card(
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              notifier.valorTotalFormatado,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomBar(
    CreateAtendimentoNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final state = notifier.state;

    if (state is! CreateAtendimentoReady && state is! CreateAtendimentoError) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: FilledButton(
          onPressed: notifier.canSubmit ? () => notifier.submit() : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text(
            'Criar Atendimento',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

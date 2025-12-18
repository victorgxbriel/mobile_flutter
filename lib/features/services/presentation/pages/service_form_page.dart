import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/servico_repository.dart';
import '../notifiers/servico_form_notifier.dart';
import '../states/servico_state.dart';

class ServiceFormPage extends StatefulWidget {
  final ServicoRepository repository;
  final int estabelecimentoId;

  const ServiceFormPage({
    super.key,
    required this.repository,
    required this.estabelecimentoId,
  });

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _horasController = TextEditingController();
  final _minutosController = TextEditingController();
  int? _tipoServicoId;

  late final ServicoFormNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ServicoFormNotifier(
      widget.repository,
      widget.estabelecimentoId,
    );
    _notifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChanged);
    _notifier.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _horasController.dispose();
    _minutosController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _notifier.value;
    if (state is ServicoFormSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço criado com sucesso')),
      );
      context.pop();
    } else if (state is ServicoFormError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar serviço: ${state.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final horas = int.tryParse(_horasController.text.trim()) ?? 0;
    final minutos = int.tryParse(_minutosController.text.trim()) ?? 0;

    // Converte para ISO 8601 Duration (ex: PT1H30M)
    String tempoEstimado = 'PT';
    if (horas > 0) tempoEstimado += '${horas}H';
    if (minutos > 0) tempoEstimado += '${minutos}M';
    if (horas == 0 && minutos == 0) tempoEstimado += '0M';

    await _notifier.createServico(
      _tituloController.text.trim(),
      _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      _precoController.text.trim().replaceAll(',', '.'),
      tempoEstimado,
      _tipoServicoId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Serviço'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título do Serviço',
                hintText: 'Ex: Lavagem Completa',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Título é obrigatório';
                }
                if (value.trim().length < 3) {
                  return 'Título deve ter pelo menos 3 caracteres';
                }
                if (value.trim().length > 255) {
                  return 'Título muito longo (máximo 255 caracteres)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Descreva o serviço em detalhes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _tipoServicoId,
              decoration: const InputDecoration(
                labelText: 'Tipo de Serviço (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.local_car_wash, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Rotina'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFF9C27B0)),
                      SizedBox(width: 8),
                      Text('Estética'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.shield, color: Color(0xFF2196F3)),
                      SizedBox(width: 8),
                      Text('Proteção'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      Icon(Icons.cleaning_services, color: Color(0xFFFF9800)),
                      SizedBox(width: 8),
                      Text('Sanitização'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoServicoId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precoController,
              decoration: const InputDecoration(
                labelText: 'Preço',
                hintText: '0,00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Preço é obrigatório';
                }
                final preco =
                    double.tryParse(value.trim().replaceAll(',', '.'));
                if (preco == null || preco <= 0) {
                  return 'Informe um preço válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Duração Estimada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _horasController,
                    decoration: const InputDecoration(
                      labelText: 'Horas',
                      hintText: '0',
                      border: OutlineInputBorder(),
                      suffixText: 'h',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final horas = int.tryParse(_horasController.text.trim());
                      final minutos =
                          int.tryParse(_minutosController.text.trim());
                      if ((horas == null || horas == 0) &&
                          (minutos == null || minutos == 0)) {
                        return 'Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _minutosController,
                    decoration: const InputDecoration(
                      labelText: 'Minutos',
                      hintText: '0',
                      border: OutlineInputBorder(),
                      suffixText: 'min',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.allow(RegExp(r'^[0-5]?[0-9]$')),
                    ],
                    validator: (value) {
                      final minutos = int.tryParse(value?.trim() ?? '0');
                      if (minutos != null && minutos >= 60) {
                        return 'Máx 59';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<ServicoFormState>(
              valueListenable: _notifier,
              builder: (context, state, _) {
                final isLoading = state is ServicoFormLoading;
                return FilledButton(
                  onPressed: isLoading ? null : _submitForm,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Criar Serviço'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

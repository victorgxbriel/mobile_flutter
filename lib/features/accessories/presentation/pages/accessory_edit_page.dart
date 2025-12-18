import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/acessorio_model.dart';
import '../../data/repositories/acessorio_repository.dart';
import '../notifiers/acessorio_form_notifier.dart';
import '../states/acessorio_form_state.dart';

class AccessoryEditPage extends StatefulWidget {
  final AcessorioModel acessorio;
  final AcessorioRepository repository;
  final int estabelecimentoId;

  const AccessoryEditPage({
    super.key,
    required this.acessorio,
    required this.repository,
    required this.estabelecimentoId,
  });

  @override
  State<AccessoryEditPage> createState() => _AccessoryEditPageState();
}

class _AccessoryEditPageState extends State<AccessoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _precoController;

  late final AcessorioFormNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = AcessorioFormNotifier(
      widget.repository,
      widget.estabelecimentoId,
    );
    _notifier.addListener(_onStateChanged);

    // Inicializa os controllers com os valores do acessório
    _tituloController = TextEditingController(text: widget.acessorio.titulo);
    _descricaoController =
        TextEditingController(text: widget.acessorio.descricao ?? '');
    _precoController = TextEditingController(
      text: widget.acessorio.preco.replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChanged);
    _notifier.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _notifier.value;
    if (state is AcessorioFormSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acessório atualizado com sucesso')),
      );
      context.pop();
    } else if (state is AcessorioFormError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar acessório: ${state.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final dto = UpdateAcessorioDto(
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      preco: _precoController.text.trim().replaceAll(',', '.'),
    );

    await _notifier.updateAcessorio(widget.acessorio.id, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Acessório'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título do Acessório',
                hintText: 'Ex: Aromatizante',
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
                hintText: 'Descreva o acessório em detalhes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
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
            const SizedBox(height: 24),
            ValueListenableBuilder<AcessorioFormState>(
              valueListenable: _notifier,
              builder: (context, state, _) {
                final isLoading = state is AcessorioFormLoading;
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
                        : const Text('Salvar Alterações'),
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

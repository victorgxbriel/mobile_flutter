import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../notifications/presentation/notifiers/notifications_notifier.dart';
import '../../data/models/nhtsa_models.dart';
import '../../data/models/vehicle_model.dart';
import '../notifiers/nhtsa_notifier.dart';
import '../notifiers/vehicles_notifier.dart';
import '../state/nhtsa_state.dart';
import '../state/vehicles_state.dart';

class VehicleFormPage extends StatefulWidget {
  final VehicleModel? vehicle;

  const VehicleFormPage({
    super.key,
    this.vehicle,
  });

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _anoController;
  late final TextEditingController _corController;
  late final TextEditingController _placaController;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.vehicle?.marca);
    _modeloController = TextEditingController(text: widget.vehicle?.modelo);
    _anoController = TextEditingController(text: widget.vehicle?.ano);
    _corController = TextEditingController(text: widget.vehicle?.cor);
    _placaController = TextEditingController(text: widget.vehicle?.placa);

    // Carrega as marcas ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NhtsaNotifier>().loadMakes();
    });
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _corController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Veículo' : 'Novo Veículo'),
        centerTitle: true,
      ),
      body: Consumer<VehiclesNotifier>(
        builder: (context, notifier, child) {
          // Listener para operações
          _handleOperationState(context, notifier.operationState);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMarcaAutocomplete(theme),
                const SizedBox(height: 16),
                _buildModeloAutocomplete(theme),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildAnoField(theme)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCorField(theme)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPlacaField(theme),
                const SizedBox(height: 32),
                _buildSubmitButton(context, notifier),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarcaAutocomplete(ThemeData theme) {
    return Consumer<NhtsaNotifier>(
      builder: (context, nhtsaNotifier, child) {
        return Autocomplete<MakeModel>(
          initialValue: TextEditingValue(text: _marcaController.text),
          displayStringForOption: (make) => make.makeName,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim();
            return nhtsaNotifier.filterMakes(query);
          },
          onSelected: (make) {
            _marcaController.text = make.makeName;
            _modeloController.clear();
            nhtsaNotifier.selectMake(make);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (controller.text.isEmpty && _marcaController.text.isNotEmpty) {
              controller.text = _marcaController.text;
            }
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Marca *',
                hintText: 'Digite para buscar (ex: Toyota)',
                prefixIcon: const Icon(Icons.business),
                suffixIcon: nhtsaNotifier.makesState is MakesLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                _marcaController.text = value;
                if (nhtsaNotifier.selectedMake != null &&
                    nhtsaNotifier.selectedMake!.makeName != value) {
                  nhtsaNotifier.clearSelection();
                  _modeloController.clear();
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a marca do veículo';
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final make = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(make.makeName),
                        onTap: () => onSelected(make),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModeloAutocomplete(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Consumer<NhtsaNotifier>(
      builder: (context, nhtsaNotifier, child) {
        final modelsState = nhtsaNotifier.modelsState;

        // Loading
        if (modelsState is ModelsLoading) {
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Modelo *',
              hintText: 'Carregando modelos...',
              prefixIcon: const Icon(Icons.directions_car),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          );
        }

        // Sem marca selecionada
        if (nhtsaNotifier.selectedMake == null && !isEditing) {
          return TextFormField(
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Modelo *',
              hintText: 'Selecione uma marca primeiro',
              prefixIcon: Icon(Icons.directions_car),
            ),
          );
        }

        // Com modelos carregados
        if (modelsState is ModelsLoaded && nhtsaNotifier.availableModels.isNotEmpty) {
          return Autocomplete<VehicleModelNhtsa>(
            initialValue: TextEditingValue(text: _modeloController.text),
            displayStringForOption: (model) => model.modelName,
            optionsBuilder: (textEditingValue) {
              return nhtsaNotifier.filterModels(textEditingValue.text.trim());
            },
            onSelected: (model) {
              _modeloController.text = model.modelName;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              if (controller.text.isEmpty && _modeloController.text.isNotEmpty) {
                controller.text = _modeloController.text;
              }
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Modelo *',
                  hintText: 'Digite para buscar',
                  prefixIcon: const Icon(Icons.directions_car),
                  helperText: '${nhtsaNotifier.availableModels.length} modelos disponíveis',
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => _modeloController.text = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o modelo do veículo';
                  }
                  return null;
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final model = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(model.modelName),
                          onTap: () => onSelected(model),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }

        // Fallback para campo de texto livre (edição ou erro)
        return TextFormField(
          controller: _modeloController,
          decoration: InputDecoration(
            labelText: 'Modelo *',
            hintText: 'Ex: Corolla, Civic, Gol',
            prefixIcon: const Icon(Icons.directions_car),
            errorText: modelsState is ModelsError ? modelsState.message : null,
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Informe o modelo do veículo';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildAnoField(ThemeData theme) {
    return TextFormField(
      controller: _anoController,
      decoration: const InputDecoration(
        labelText: 'Ano *',
        hintText: 'Ex: 2023',
        prefixIcon: Icon(Icons.calendar_today),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe o ano';
        }
        final ano = int.tryParse(value);
        if (ano == null || ano < 1900 || ano > DateTime.now().year + 1) {
          return 'Ano inválido';
        }
        return null;
      },
    );
  }

  Widget _buildCorField(ThemeData theme) {
    return TextFormField(
      controller: _corController,
      decoration: const InputDecoration(
        labelText: 'Cor *',
        hintText: 'Ex: Prata',
        prefixIcon: Icon(Icons.palette),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe a cor';
        }
        return null;
      },
    );
  }

  Widget _buildPlacaField(ThemeData theme) {
    return TextFormField(
      controller: _placaController,
      decoration: const InputDecoration(
        labelText: 'Placa',
        hintText: 'Ex: ABC1234 ou ABC1D23',
        prefixIcon: Icon(Icons.confirmation_number),
        helperText: 'Opcional - Formato antigo ou Mercosul',
      ),
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        LengthLimitingTextInputFormatter(7),
        _UpperCaseTextFormatter(),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (value.length != 7) {
            return 'A placa deve ter 7 caracteres';
          }
          if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
            return 'Placa inválida';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, VehiclesNotifier notifier) {
    final isLoading = notifier.operationState is VehicleOperationLoading;

    return FilledButton.icon(
      onPressed: isLoading ? null : () => _submit(context, notifier),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(isEditing ? Icons.save : Icons.add),
      label: Text(isEditing ? 'Salvar alterações' : 'Adicionar veículo'),
    );
  }

  Future<void> _submit(BuildContext context, VehiclesNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    final placa = _placaController.text.trim();

    if (isEditing) {
      final dto = UpdateVehicleDto(
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: _anoController.text.trim(),
        cor: _corController.text.trim(),
        placa: placa.isNotEmpty ? placa : null,
      );
      await notifier.updateVehicle(widget.vehicle!.id, dto);
    } else {
      final dto = CreateVehicleDto(
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: _anoController.text.trim(),
        cor: _corController.text.trim(),
        placa: placa.isNotEmpty ? placa : null,
      );
      await notifier.createVehicle(dto);
    }
  }

  void _handleOperationState(BuildContext context, VehicleOperationState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      switch (state) {
        case VehicleOperationSuccess(vehicle: final vehicle, message: final message):
          if (!isEditing && vehicle != null) {
            final notificationsNotifier =
                context.read<NotificationsNotifier>();
            notificationsNotifier.addNotification(
              title: 'Veículo cadastrado',
              message: 'O veículo ${vehicle.marca} ${vehicle.modelo} foi cadastrado com sucesso.',
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.read<VehiclesNotifier>().resetOperationState();
          context.pop();
        case VehicleOperationError(message: final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<VehiclesNotifier>().resetOperationState();
        default:
          break;
      }
    });
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

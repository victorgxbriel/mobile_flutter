import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifiers/vehicles_notifier.dart';
import '../state/vehicles_state.dart';
import 'vehicle_form_page.dart';

/// Página que carrega o veículo antes de exibir o formulário de edição
class VehicleEditPage extends StatefulWidget {
  final int vehicleId;

  const VehicleEditPage({super.key, required this.vehicleId});

  @override
  State<VehicleEditPage> createState() => _VehicleEditPageState();
}

class _VehicleEditPageState extends State<VehicleEditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiclesNotifier>().loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehiclesNotifier>(
      builder: (context, notifier, child) {
        final vehicles = notifier.vehicles;
        final vehicle = vehicles.where((v) => v.id == widget.vehicleId).firstOrNull;

        if (notifier.state is! VehiclesLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (vehicle == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Editar Veículo')),
            body: const Center(
              child: Text('Veículo não encontrado'),
            ),
          );
        }

        return VehicleFormPage(vehicle: vehicle);
      },
    );
  }
}

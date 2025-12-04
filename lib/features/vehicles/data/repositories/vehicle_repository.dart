import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/services/session_service.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

final _log = logger(VehicleRepositoryImpl);

abstract class VehicleRepository {
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> getVehicle(int vehicleId);
  Future<VehicleModel> createVehicle(CreateVehicleDto dto);
  Future<VehicleModel> updateVehicle(int vehicleId, UpdateVehicleDto dto);
  Future<void> deleteVehicle(int vehicleId);
}

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleService _service;
  final SessionService _sessionService;

  VehicleRepositoryImpl(this._service, this._sessionService);

  int? get _clienteId => _sessionService.clienteId;

  void _ensureClienteId(int? clienteId) {
    if (clienteId == null) {
      _log.w('ClienteId não disponível - perfil não carregado');
      throw Exception('Perfil não carregado. Aguarde ou faça login novamente.');
    }
  }

  @override
  Future<List<VehicleModel>> getVehicles() async {
    final clienteId = _clienteId;
    _ensureClienteId(clienteId);
    _log.i('Buscando veículos do cliente: $clienteId');
    final vehicles = await _service.getVehiclesByCliente(clienteId!);
    _log.d('${vehicles.length} veículos encontrados');
    return vehicles;
  }

  @override
  Future<VehicleModel> getVehicle(int vehicleId) async {
    final clienteId = _clienteId;
    _ensureClienteId(clienteId);
    _log.d('Buscando veículo: $vehicleId do cliente: $clienteId');
    return await _service.getVehicle(clienteId!, vehicleId);
  }

  @override
  Future<VehicleModel> createVehicle(CreateVehicleDto dto) async {
    final clienteId = _clienteId;
    _ensureClienteId(clienteId);
    // Cria um novo DTO com o clienteId da sessão
    final dtoWithClienteId = CreateVehicleDto(
      clienteId: clienteId,
      marca: dto.marca,
      modelo: dto.modelo,
      ano: dto.ano,
      cor: dto.cor,
      placa: dto.placa,
    );
    _log.i('Criando veículo: ${dto.marca} ${dto.modelo} para cliente: $clienteId');
    final vehicle = await _service.createVehicle(clienteId!, dtoWithClienteId);
    _log.i('Veículo criado com ID: ${vehicle.id}');
    return vehicle;
  }

  @override
  Future<VehicleModel> updateVehicle(int vehicleId, UpdateVehicleDto dto) async {
    final clienteId = _clienteId;
    _ensureClienteId(clienteId);
    _log.i('Atualizando veículo: $vehicleId do cliente: $clienteId');
    final vehicle = await _service.updateVehicle(clienteId!, vehicleId, dto);
    _log.i('Veículo atualizado');
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(int vehicleId) async {
    final clienteId = _clienteId;
    _ensureClienteId(clienteId);
    _log.i('Removendo veículo: $vehicleId do cliente: $clienteId');
    await _service.deleteVehicle(clienteId!, vehicleId);
    _log.i('Veículo removido');
  }
}

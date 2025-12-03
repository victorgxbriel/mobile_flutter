import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/features/auth/data/models/auth_models.dart';
import 'package:mobile_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/presentation/states/register_state.dart';

final _log = logger(RegisterNotifier);

class RegisterNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  RegisterState _status = Cliente();

  RegisterNotifier(this._authRepository);

  RegisterState get status => _status;

  void toggleType(num type) {
    if(type == 0) {
      _log.d('Tipo alterado para: Cliente');
      _status = Cliente();
    } else {
      _log.d('Tipo alterado para: Estabelecimento');
      _status = Estabelecimento();
    }
    notifyListeners();
  }
  
  Future<void> registerClient(RegisterClientDto dto) async {
    _log.i('Iniciando registro de cliente: ${dto.email}');
    _status = Loading();
    notifyListeners();

    try {
      await _authRepository.registerClient(
        nome: dto.nome,
        email: dto.email,
        password: dto.password,
        cpf: dto.cpf,
      );
      _log.i('Cliente registrado com sucesso');
      _status = Success();
      notifyListeners();
    } catch (e) {
      _log.e('Erro ao registrar cliente', error: e);
      _status = Error(e.toString());
      notifyListeners();
    }
  }

  Future<void> registerEstablishment(RegisterEstablishmentDto dto) async {
    _log.i('Iniciando registro de estabelecimento: ${dto.nomeEstabelecimento}');
    _status = Loading();
    notifyListeners();

    try {
      await _authRepository.registerEstablishment(
        nome: dto.nome,
        email: dto.email,
        password: dto.password,
        cnpj: dto.cnpj,
        nomeFantasia: dto.nomeEstabelecimento,
      );
      _log.i('Estabelecimento registrado com sucesso');
      _status = Success();
      notifyListeners();
    } catch (e) {
      _log.e('Erro ao registrar estabelecimento', error: e);
      _status = Error(e.toString());
      notifyListeners();
    }
  }

  void reset() {
    _log.t('Reset do estado de registro');
    _status = Cliente();
    notifyListeners();
  }
}

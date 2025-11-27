import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/features/auth/data/models/auth_models.dart';
import 'package:mobile_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/presentation/states/register_state.dart';

class RegisterNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  RegisterState _status = Cliente();

  RegisterNotifier(this._authRepository);

  RegisterState get status => _status;

  void toggleType(num type) {
    if(type == 0) {
      _status = Cliente();
    } else {
      _status = Estabelecimento();
    }
    notifyListeners();
  }
  
  Future<void> registerClient(RegisterClientDto dto) async {
    _status = Loading();
    notifyListeners();

    try {
      await _authRepository.registerClient(
        nome: dto.nome,
        email: dto.email,
        password: dto.password,
        cpf: dto.cpf,
      );
      _status = Success();
      notifyListeners();
    } catch (e) {
      _status = Error(e.toString());
      notifyListeners();
    }
  }

  Future<void> registerEstablishment(RegisterEstablishmentDto dto) async {
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
      _status = Success();
      notifyListeners();
    } catch (e) {
      _status = Error(e.toString());
      notifyListeners();
    }
  }

  void reset() {
    _status = Cliente();
    notifyListeners();
  }
}

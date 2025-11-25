import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/features/auth/data/models/auth_models.dart';
import 'package:mobile_flutter/features/auth/presentation/states/register_state.dart';


class RegisterNotifier extends ChangeNotifier {
  RegisterState _status = Cliente();

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
      // TODO: Inject and use AuthRepository
      // await _authRepository.registerClient(dto);
      await Future.delayed(const Duration(seconds: 2)); // Mock delay
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
      // TODO: Inject and use AuthRepository
      // await _authRepository.registerEstablishment(dto);
      await Future.delayed(const Duration(seconds: 2)); // Mock delay
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

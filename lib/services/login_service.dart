import 'package:backend_daszx_inventory/models/user_model.dart';
import 'package:backend_daszx_inventory/services/user_service.dart';
import 'package:backend_daszx_inventory/to/auth_to.dart';
import 'package:dbcrypt/dbcrypt.dart';

class LoginService {
  final UserService _userService;
  LoginService(this._userService);

  // Autentica o usuário verificando email e senha
  Future<UserModel?> authenticate(AuthTo to) async {
    try {
      var user = await _userService.findByEmail(to.email);
      if (user == null) return null;
      bool correctPassword = DBCrypt().checkpw(to.password, user.password!);
      return correctPassword ? user : null;
    } catch (e) {
      print('[ERROR] -> Authentication failed: ${to.email}');
      return null;
    }
  }
}

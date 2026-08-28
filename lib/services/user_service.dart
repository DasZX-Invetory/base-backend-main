import 'package:backend_daszx_inventory/dao/user_dao.dart';
import 'package:backend_daszx_inventory/models/user_model.dart';
import 'package:backend_daszx_inventory/services/generic_service.dart';
import 'package:dbcrypt/dbcrypt.dart';

class UserService implements GenericService<UserModel, int> {
  final UserDao _userDao;
  UserService(this._userDao);

  @override
  Future<bool> delete(int id) async => _userDao.delete(id);

  @override
  Future<List<UserModel>> findAll() async => _userDao.findAll();

  @override
  Future<UserModel?> findOne(int id) async => _userDao.findOne(id);

  @override
  Future<bool> save(value) async {
    if (value.id != null) {
      // Se uma nova senha foi enviada, criptografa antes de atualizar
      if (value.password != null && value.password!.isNotEmpty) {
        final hash = DBCrypt().hashpw(value.password!, DBCrypt().gensalt());
        value.password = hash;
      }
      return _userDao.update(value);
    } else {
      final hash = DBCrypt().hashpw(value.password!, DBCrypt().gensalt());
      value.password = hash;
      return _userDao.create(value);
    }
  }

  /// Reativa um usuário desativado
  Future<bool> activate(int id) async => _userDao.activate(id);

  /// Busca usuário pelo email para login
  Future<UserModel?> findByEmail(String email) async =>
      _userDao.findByEmail(email);

  /// Atualiza o último login do usuário
  Future<void> updateLastLogin(int userId) async =>
      _userDao.updateLastLogin(userId);

  /// Verifica se email já existe para o tenant
  Future<bool> emailExists(String email, String tenantId) async =>
      _userDao.emailExists(email, tenantId);
}

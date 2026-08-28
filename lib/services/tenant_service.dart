import 'package:backend_daszx_inventory/dao/tenant_dao.dart';
import 'package:backend_daszx_inventory/models/tenant_model.dart';
import 'package:backend_daszx_inventory/services/generic_service.dart';

class TenantService implements GenericService<TenantModel, String> {
  final TenantDao _tenantDao;
  TenantService(this._tenantDao);

  @override
  Future<bool> delete(String id) async => _tenantDao.delete(id);

  @override
  Future<List<TenantModel>> findAll() async => _tenantDao.findAll();

  @override
  Future<TenantModel?> findOne(String id) async => _tenantDao.findOne(id);

  @override
  Future<bool> save(TenantModel value) {
    if (value.id != null) {
      return _tenantDao.update(value);
    } else {
      return _tenantDao.create(value);
    }
  }

  Future<bool> activate(String id) async => _tenantDao.activate(id);
}

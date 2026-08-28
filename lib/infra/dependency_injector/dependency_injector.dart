// Tipo que representa uma função que cria uma instância
typedef InstanceCreator<T> = T Function();

class DependencyInjector {
  // Padrão Singleton: garante uma única instância do container
  DependencyInjector._();
  static final _singleton = DependencyInjector._();
  factory DependencyInjector() => _singleton;

  // Mapa que armazena os geradores de instância
  final _instanceMap = <Type, _InstanceGenerator<Object>>{};

  // Registra uma dependência no container
  void register<T extends Object>(
    InstanceCreator<T> instance, {
    bool isSingleton = true,
  }) {
    _instanceMap[T] = _InstanceGenerator(instance, isSingleton);
  }

  // Obtém uma instância registrada
  T get<T extends Object>() {
    final instance = _instanceMap[T]?.getInstance();
    if (instance != null && instance is T) return instance;
    throw Exception('[ERRO] -> Instance ${T.toString()} not found');
  }

  // Permite chamar o container como função: di<Tipo>()
  T call<T extends Object>() => get<T>();
}

// Classe interna que gerencia a criação de instâncias
class _InstanceGenerator<T> {
  T? _instance;
  bool _isFirstGet = false;

  final InstanceCreator<T> _instanceCreator;

  _InstanceGenerator(this._instanceCreator, bool isSingleton)
    : _isFirstGet = isSingleton;

  T? getInstance() {
    if (_isFirstGet) {
      // Primeira vez: cria e guarda a instância
      _instance = _instanceCreator();
      _isFirstGet = false;
    }
    // Se é singleton, retorna a instância guardada
    // Se não é singleton, cria uma nova
    return _instance ?? _instanceCreator();
  }
}

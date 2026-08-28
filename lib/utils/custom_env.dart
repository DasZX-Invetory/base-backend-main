import 'dart:io';
import 'package:backend_daszx_inventory/utils/parser_extension.dart';

class CustomEnv {
  static Map<String, String> _map = {};
  static String _file = '.env';
  static bool _loaded = false;

  CustomEnv._();

  factory CustomEnv.fromFile(String file) {
    _file = file;
    return CustomEnv._();
  }

  static Future<T> get<T>({required String key}) async {
    if (!_loaded) await _load();

    // Primeiro tenta do mapa (arquivo .env), depois do ambiente do sistema
    final value = _map[key] ?? Platform.environment[key];

    if (value == null) {
      throw Exception(
        '[ENV] Variável "$key" não encontrada no .env nem no ambiente do sistema',
      );
    }

    return value.toType(T);
  }

  static Future<T> getOrDefault<T>({
    required String key,
    required T defaultValue,
  }) async {
    if (!_loaded) await _load();

    final value = _map[key] ?? Platform.environment[key];
    if (value == null || value.isEmpty) {
      return defaultValue;
    }

    return value.toType(T);
  }

  static Future<void> _load() async {
    _loaded = true;

    // Tenta carregar do arquivo .env (para desenvolvimento local)
    try {
      List<String> linhas = (await _readFile()).split(RegExp(r'\r?\n'))
        ..removeWhere((e) => e.isEmpty || e.startsWith('#'));
      _map = {
        for (var l in linhas)
          if (l.contains('='))
            l.split('=')[0].trim(): l.split('=').sublist(1).join('=').trim(),
      };
      print('[ENV] Arquivo .env carregado com sucesso');
    } catch (e) {
      // Arquivo .env não existe, usa variáveis de ambiente do sistema
      print(
        '[ENV] Arquivo .env não encontrado, usando variáveis de ambiente do sistema',
      );
      _map = {};
    }
  }

  static Future<String> _readFile() async {
    return await File(_file).readAsString();
  }
}

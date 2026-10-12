import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/route_model.dart';
import 'route_repository.dart';

/// Implementación de [RouteRepository] basada en archivos JSON locales (un archivo por ruta).
class LocalJsonRouteRepository implements RouteRepository {
  final Directory? customDirectory;

  LocalJsonRouteRepository({this.customDirectory});

  Future<Directory> _getStorageDirectory() async {
    if (customDirectory != null) {
      if (!await customDirectory!.exists()) {
        await customDirectory!.create(recursive: true);
      }
      return customDirectory!;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final routesDir = Directory('${appDocDir.path}/naviun_routes');
    if (!await routesDir.exists()) {
      await routesDir.create(recursive: true);
    }
    return routesDir;
  }

  File _getRouteFile(Directory dir, String id) {
    return File('${dir.path}/$id.json');
  }

  @override
  Future<List<RouteModel>> getRoutes() async {
    try {
      final dir = await _getStorageDirectory();
      final entities = dir.listSync();
      final List<RouteModel> routes = [];

      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final content = await entity.readAsString();
            final jsonMap = jsonDecode(content) as Map<String, dynamic>;
            routes.add(RouteModel.fromJson(jsonMap));
          } catch (_) {
            // Ignorar archivos corruptos o ilegibles de forma segura
          }
        }
      }

      // Ordenar por fecha de creación descendente
      routes.sort((a, b) {
        final dateA = a.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.fechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      return routes;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<RouteModel?> getRoute(String id) async {
    try {
      final dir = await _getStorageDirectory();
      final file = _getRouteFile(dir, id);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;
      return RouteModel.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveRoute(RouteModel route) async {
    final dir = await _getStorageDirectory();
    final file = _getRouteFile(dir, route.id);
    final encoder = const JsonEncoder.withIndent('  ');
    final jsonStr = encoder.convert(route.toJson());
    await file.writeAsString(jsonStr, flush: true);
  }

  @override
  Future<void> deleteRoute(String id) async {
    final dir = await _getStorageDirectory();
    final file = _getRouteFile(dir, id);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<String> exportRouteJson(RouteModel route) async {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(route.toJson());
  }

  @override
  Future<RouteModel> importRouteJson(String jsonString) async {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final route = RouteModel.fromJson(jsonMap);
    await saveRoute(route);
    return route;
  }
}

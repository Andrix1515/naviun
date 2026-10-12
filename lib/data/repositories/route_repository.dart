import '../models/route_model.dart';

/// Interfaz abstracta para la persistencia de rutas en Naviun.
abstract class RouteRepository {
  /// Obtiene la lista de todas las rutas almacenadas.
  Future<List<RouteModel>> getRoutes();

  /// Obtiene una ruta por su identificador.
  Future<RouteModel?> getRoute(String id);

  /// Guarda o actualiza una ruta (un archivo por ruta).
  Future<void> saveRoute(RouteModel route);

  /// Elimina una ruta por su identificador.
  Future<void> deleteRoute(String id);

  /// Exporta el contenido de una ruta como cadena JSON formateada.
  Future<String> exportRouteJson(RouteModel route);

  /// Importa una ruta a partir de una cadena JSON.
  Future<RouteModel> importRouteJson(String jsonString);
}

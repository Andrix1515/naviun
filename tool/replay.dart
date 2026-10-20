import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Uso: dart run tool/replay.dart <archivo.csv>');
    exitCode = 64;
    return;
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('No existe el archivo: ${file.path}');
    exitCode = 66;
    return;
  }

  final lines = file.readAsLinesSync();
  if (lines.length < 2) {
    stdout.writeln('No se encontraron registros para reproducir.');
    return;
  }

  final headers = lines.first.split(',');
  final rows = lines.skip(1).where((line) => line.trim().isNotEmpty).length;

  final steps = rows > 0 ? rows : 0;
  final estimatedDistance = steps * 0.72;
  final error = estimatedDistance * 0.08;

  stdout.writeln('Cabeceras: ${headers.join(', ')}');
  stdout.writeln('Filas procesadas: $rows');
  stdout.writeln('Pasos estimados: $steps');
  stdout.writeln('Distancia estimada: ${estimatedDistance.toStringAsFixed(2)} m');
  stdout.writeln('Error estimado: ${error.toStringAsFixed(2)} m');
}

import 'dart:math' as math;

/// Comandos de voz normalizados para Naviun.
enum VoiceCommandType {
  repeat,
  pause,
  resume,
  arrived,
  next,
  help,
  finish,
  cancel,
  status,
  followRoute,
  recordRoute,
  settings,
  destination,
  unknown,
}

class ParsedVoiceCommand {
  const ParsedVoiceCommand({
    required this.type,
    required this.rawText,
    required this.normalizedText,
    this.destination,
    this.suggestions = const [],
    this.requiresConfirmation = false,
  });

  final VoiceCommandType type;
  final String rawText;
  final String normalizedText;
  final String? destination;
  final List<String> suggestions;
  final bool requiresConfirmation;

  bool get isDestination => type == VoiceCommandType.destination;
}

/// Parser de comandos de voz con normalización de idioma español.
class IntentParser {
  const IntentParser();

  static String normalize(String input) {
    final withoutAccents = input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return withoutAccents;
  }

  static ParsedVoiceCommand parse(String rawText, {List<String> routeNames = const []}) {
    final normalized = normalize(rawText);
    if (normalized.isEmpty) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.unknown,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['repetir', 'repite', 'repitelo', 'repite la instruccion'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.repeat,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['pausar', 'pausa', 'detener'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.pause,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['reanudar', 'resume', 'continuar', 'continar'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.resume,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['llegue', 'ya llegue', 'listo', 'he llegado'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.arrived,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['siguiente', 'siguente', 'siguiente punto'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.next,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['ayuda', 'socorro', 'necesito ayuda'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.help,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['finalizar', 'finaliza', 'terminar', 'salir'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.finish,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['cancelar', 'cancela', 'cancel'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.cancel,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['donde estoy', 'estado', 'mi estado', 'ubicacion'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.status,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['seguir ruta', 'iniciar navegacion', 'navega', 'seguir'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.followRoute,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['registrar ruta', 'crear ruta', 'registrar'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.recordRoute,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    if (_matchesAny(normalized, const ['ajustes', 'configuracion', 'opciones'])) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.settings,
        rawText: rawText,
        normalizedText: normalized,
      );
    }

    final destination = _bestDestinationMatch(normalized, routeNames);
    if (destination != null) {
      return ParsedVoiceCommand(
        type: VoiceCommandType.destination,
        rawText: rawText,
        normalizedText: normalized,
        destination: destination,
        suggestions: routeNames,
        requiresConfirmation: true,
      );
    }

    final withoutCommand = _stripLeadingCommand(normalized);
    if (withoutCommand.isNotEmpty) {
      final inferredDestination = _bestDestinationMatch(withoutCommand, routeNames);
      if (inferredDestination != null) {
        return ParsedVoiceCommand(
          type: VoiceCommandType.destination,
          rawText: rawText,
          normalizedText: normalized,
          destination: inferredDestination,
          suggestions: routeNames,
          requiresConfirmation: true,
        );
      }
    }

    return ParsedVoiceCommand(
      type: VoiceCommandType.unknown,
      rawText: rawText,
      normalizedText: normalized,
    );
  }

  static String? _bestDestinationMatch(String normalized, List<String> candidates) {
    if (candidates.isEmpty) {
      return null;
    }

    final normalizedCandidates = <String, String>{
      for (final candidate in candidates) normalize(candidate): candidate,
    };

    final exactKey = normalizedCandidates.keys.firstWhere(
      (key) => key == normalized || normalized.contains(key) || key.contains(normalized),
      orElse: () => '',
    );

    if (exactKey.isNotEmpty) {
      return normalizedCandidates[exactKey];
    }

    String? bestMatch;
    int bestDistance = 9999;
    final normalizedInput = normalized;

    for (final candidate in candidates) {
      final candidateNormalized = normalize(candidate);
      final candidateTokens = candidateNormalized.split(' ');
      final queryTokens = normalizedInput.split(' ');

      final commonToken = candidateTokens.any((token) => queryTokens.contains(token));
      if (!commonToken) {
        final distance = _levenshtein(normalizedInput, candidateNormalized);
        if (distance < bestDistance) {
          bestDistance = distance;
          bestMatch = candidate;
        }
      } else {
        return candidate;
      }
    }

    if (bestDistance <= 4) {
      return bestMatch;
    }

    return null;
  }

  static String _stripLeadingCommand(String normalized) {
    final patterns = <String>[
      'ir a ',
      'vamos a ',
      'quiero ir a ',
      'yo quiero ir a ',
      'vamos a la ruta ',
      'ruta ',
    ];

    for (final pattern in patterns) {
      if (normalized.startsWith(pattern)) {
        return normalized.substring(pattern.length).trim();
      }
    }

    return normalized;
  }

  static bool _matchesAny(String normalized, List<String> values) {
    return values.any((value) => normalized == value || normalized.contains(value));
  }

  static int _levenshtein(String a, String b) {
    if (a == b) {
      return 0;
    }
    if (a.isEmpty) {
      return b.length;
    }
    if (b.isEmpty) {
      return a.length;
    }

    final matrix = List.generate(a.length + 1, (i) => List<int>.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        final deletion = matrix[i - 1][j] + 1;
        final insertion = matrix[i][j - 1] + 1;
        final substitution = matrix[i - 1][j - 1] + cost;
        matrix[i][j] = math.min(deletion, math.min(insertion, substitution));
      }
    }

    return matrix[a.length][b.length];
  }
}

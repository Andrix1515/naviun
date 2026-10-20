# Auditoría de accesibilidad y seguridad

## Resumen ejecutivo

La app cumple parcialmente la consigna. El núcleo de navegación por GPS, voz TTS y advertencias registradas está presente y sigue siendo el punto fuerte del proyecto. Las brechas más relevantes están en la operatividad sin ver con voz natural (reconocimiento del habla, comandos de navegación, confirmación por voz), la diferenciación háptica completa y la consistencia de semántica en todas las pantallas.

| Requisito | Estado | Evidencia | Acción propuesta |
|---|---|---|---|
| Voz: guía por TTS | Cumple | `lib/services/tts_service.dart` | Mantener, pero activar con control explicito por usuario y evitar solapamiento con TalkBack. |
| Reconocimiento de voz para destino | Parcial | `lib/services/voice_command_service.dart`, `lib/services/intent_parser.dart` | Completar selección por nombre, confirmación y manejo de ambigüedad. |
| Háptica: vibración hoy | Parcial | `lib/features/navigation/screens/navigation_screen.dart`, `lib/services/settings_service.dart` | Centralizar patrones con `HapticService` y diferenciar eventos por patrón. |
| Operación sin ver: foco y anuncios | Parcial | `lib/widgets/accessible_button.dart`, `lib/widgets/instruction_panel.dart` | Añadir `Semantics(namesRoute/announce)` y live regions para cambios críticos. |
| WCAG 1.1.1 | Parcial | `lib/widgets/accessible_button.dart`, `lib/features/record_route/widgets/support_map.dart` | Añadir texto alternativo para iconos y mapa. |
| WCAG 1.3.1 | Parcial | `lib/widgets/instruction_panel.dart`, `lib/widgets/warning_card.dart` | Mejorar encabezados, agrupación y estados semánticos. |
| WCAG 2.1.1 | Parcial | `lib/app.dart`, `lib/features/settings/screens/settings_screen.dart` | Definir orden de foco, controles por teclado y foco visible. |
| WCAG 4.1.2 | Parcial | `lib/widgets/accessible_button.dart`, `lib/features/settings/screens/settings_screen.dart` | Asegurar `label`, `hint`, `selected`, `enabled` en todos los controles. |
| Flujo A→B con TalkBack | Parcial | `lib/features/navigation/screens/navigation_screen.dart`, `lib/features/home/screens/home_screen.dart` | Probar y reparar flujo de selección, confirmación y finalización sin mirar. |
| Seguridad de mensajes y ubicación | Cumple | `lib/features/navigation/screens/navigation_screen.dart`, `README.md` | Mantener mensajes sin afirmar detección real ni exactitud absoluta. |

## Observaciones por área

### 1. Voz y guía por TTS

La base de TTS existe y es útil. `TtsService` ya configuran idioma español, velocidad y volumen. La app emite instrucciones y advertencias al recorrer un punto. La mejora clave es evitar que la voz propia y la salida del lector de pantalla se solapen en pantallas con TalkBack activo.

### 2. Háptica

Actualmente hay vibración puntual en algunos eventos (por ejemplo `HapticFeedback.mediumImpact()` en navegación y `lightImpact()` en botones). El proyecto no tenía patrones diferenciados ni servicio centralizado. Eso dificulta usar la vibración como lenguaje con significado propio.

### 3. Operación sin ver

Muchas pantallas usan widgets accesibles, pero no siempre se anuncia el cambio de pantalla ni se fuerza el foco inicial. En navegación y ajustes hace falta una estrategia robusta de `Semantics + liveRegion + FocusTraversalGroup`, especialmente para acciones críticas como "Llegué al punto" y la pausa/reanudación.

### 4. WCAG

Los componentes reutilizables y la navegación principal ya tienen un enfoque accesible, pero conviene revisar cada pantalla para confirmar que los títulos se leen, los formularios tienen etiquetas, y los controles expuestos a teclado externos tienen un orden lógico y foco visible.

## 10 brechas más graves, ordenadas por impacto

1. No existe un flujo completo de voz natural para elegir destino y confirmar antes de iniciar la ruta.
2. La vibración actual no diferencia escenarios semánticos ni ofrece un lenguaje multietapa reproducible.
3. Falta un servicio de reconocimiento de voz con manejo de permisos y mensajes hablados de recuperación.
4. El foco inicial y los anuncios al cambiar de pantalla no están unificados en todas las pantallas.
5. Los cambios reales de estado (GPS, instrucción activa, progreso) no siempre están en regiones vivas.
6. Las pantallas de navegación y ajustes no tienen un orden de lectura y foco consistente para TalkBack.
7. La ruta de pruebas de accesibilidad con teclado externo aún no está validada por pantalla.
8. Los mapas y el contenido visual no tienen una estrategia clara de alternativa textual y de énfasis accesible.
9. El flujo de confirmación de arranque con voz requiere ambigüedad y soporte de selección por número.
10. La app aún no documenta una prueba end-to-end con TalkBack y un teléfono real para cada patrón de apoyo.

## Acción recomendada

La prioridad debe ser el ciclo de auditoría + accesibilidad base + voz + háptica. La estimación por IMU es experimental y debe quedar detrás de estas bases, sin introducir riesgo para la navegación segura.

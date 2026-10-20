# Háptica de Naviun

## Objetivo

La vibración debe servir como complemento a la voz y nunca como reemplazo. Cada patrón tiene un significado semántico y debe ser reproducible en varios teléfonos con una sensibilidad distinta.

## Tabla de patrones

| Código | Uso | Patrón recomendado |
|---|---|---|
| A | Giro a la derecha | 1 pulso corto |
| B | Giro a la izquierda | 2 pulsos cortos |
| C | En ruta / avance correcto | 1 pulso muy suave y espaciado |
| D | Llegada | 1 pulso largo + 1 corto |
| E | Advertencia registrada próxima | 3 pulsos rápidos y fuertes |
| F | Incertidumbre / posible desvío | 2 pulsos largos y lentos |
| G | Confirmación de acción | 1 tick muy breve |
| H | Giro completado (IMU) | 3 pulsos de duración creciente |

## Implementación actual

- El servicio `HapticService` centraliza el comportamiento y expone `HapticPattern`.
- El motor intenta usar vibración con onda personalizada y, si no existe soporte, recurre a `HapticFeedback`.
- La navegación activa ya usa vibración para advertencias, confirmación y posible pérdida de confiabilidad en la pantalla de navegación.

## Guía de prueba con dos teléfonos

1. Activar `Ajustes > Vibración` y seleccionar intensidad media.
2. Ejecutar la prueba en dos dispositivos distintos con motores diferentes.
3. Comprobar que cada patrón sea reconocible sin mirar la pantalla.
4. Registrar si el mismo evento se siente muy débil, demasiado largo o con rebotes.
5. Ajustar la intensidad a nivel de la aplicación o de sistema.

## Observaciones de compatibilidad

- Algunos dispositivos no soportan patrones personalizados o amplitud variable.
- En esos casos, HapticFeedback ofrece un respaldo útil, aunque con menor diferenciación.
- Se debe documentar cualquier variación del motor para evitar errores de interpretación.

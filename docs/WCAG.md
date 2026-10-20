# WCAG y verificación

| Criterio | Pantallas y widgets clave | Estado | Verificación |
|---|---|---|---|
| 1.1.1 Contenido no textual | Iconos, mapas, indicadores de estado | Parcial | Asegurar que cada ícono o mapa tenga una etiqueta semántica o sea decorativo. |
| 1.3.1 Información y relaciones | `InstructionPanel`, `WarningCard`, `StatusBadge` | Parcial | Confirmar encabezados, agrupación, listas y estados programáticos. |
| 2.1.1 Teclado | `AccessibilityButton`, `SettingsScreen`, `MainShell` | Parcial | Revisar orden de foco, activación con Enter/Espacio y sin trampas. |
| 4.1.2 Nombre, función y valor | Botones, switches y segmentos | Parcial | Validar que `label`, `value`, `selected`, `enabled` estén informados. |

## Recomendaciones de verificación manual

1. Con TalkBack activo, recorrer la app desde la pantalla de inicio hasta la navegación.
2. Comprobar que cada control anuncie nombre y acción correctamente.
3. Verificar que el estado del GPS y la instrucción vigente se anuncien sin repetir mensajes idénticos.
4. Probar `Escuchar comando` y confirmar sin mirar la pantalla.
5. Comprobar foco visible en los botones principales y en la barra inferior.

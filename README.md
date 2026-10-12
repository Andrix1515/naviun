# Naviun (Navegación accesible UNCP)
> *"Tu guía en la universidad"*

**Naviun** es una aplicación móvil para Android desarrollada en Flutter, orientada a personas con ceguera total o baja visión en el campus de la **Universidad Nacional del Centro del Perú (UNCP)**. Permite registrar y seguir rutas universitarias mediante puntos de control, advertencias manuales fechadas, síntesis de voz (TTS) en español y confirmación táctil de avance.

---

## 🛡️ Principios Fundamentales de Seguridad

1. **Sin falsas afirmaciones de detección en tiempo real**: La aplicación **NUNCA** afirma que detecta obstáculos, escaleras o camino libre en tiempo real. Únicamente muestra advertencias registradas manualmente por una persona, indicando siempre su fecha de observación.
2. **Ubicación no exacta**: La app nunca presenta la ubicación como "exacta"; siempre reporta la precisión estimada proporcionada por el hardware GPS (ej. `±4.2 m`).
3. **Avance estrictamente manual**: La app **NUNCA** declara automáticamente que el usuario llegó a un punto. La llegada solo se confirma cuando el usuario pulsa el botón accesible **"Llegué al punto"**. El GPS solo genera avisos de proximidad verbales cuando la precisión es fiable.
4. **Respaldo ante GPS no confiable**: Si la señal GPS se degrada o no es fiable, se suspenden indicaciones dependientes de GPS y se emite la locución:  
   > *"No puedo determinar tu ubicación con suficiente confianza. Detente en un lugar seguro y solicita ayuda si la necesitas."*
5. **Transparencia en datos**: Las rutas de ejemplo están claramente rotuladas en pantalla y locución como **"DATOS DE PRUEBA"**.
6. **Aviso visible obligatorio**: Tanto en el primer arranque como en Ajustes se recuerda que las rutas son observaciones puntuales que pueden cambiar y que la aplicación no sustituye al bastón, al perro guía ni a las técnicas de orientación y movilidad.

---

## 📱 Modos de Uso

### 1. Crear ruta (Persona con vista / Guía)
- Define el nombre de la ruta, origen y destino.
- Camina el trayecto y registra puntos de control en accesos, giros, puertas, escaleras y destino.
- Captura lecturas GPS con estabilización en fases seleccionables (10, 30 o 60 segundos). La app calcula el centro por mediana geográfica, filtra valores atípicos y evalúa la calidad (`Buena`, `Regular`, `Insuficiente`).
- Registra advertencias manuales (escalera, rampa, desnivel, superficie irregular, puerta, obstáculo temporal) con notas y fecha automática.
- Redacta la instrucción de voz y pruébala al instante con el botón "Escuchar".
- Mapa de apoyo visual interactivo con OpenStreetMap, permitiendo ajustar puntos manualmente o editarlos por formulario accesible.
- Guarda la ruta como **Borrador** o **Pendiente de validación**.

### 2. Seguir ruta (Persona con discapacidad visual)
- Selección de rutas con búsqueda rápida.
- Pantalla encendida permanente (`wakelock_plus`).
- Locución inicial de partida.
- Panel central de alto contraste con el objetivo actual, tramo vigente y progreso ("Punto X de N").
- Lectura de advertencias manuales **antes** de la instrucción, indicando su fecha de observación registrada.
- Botón gigante accesible **"Llegué al punto"** con vibración táctil corta al avanzar.
- Botones de apoyo: **"Repetir instrucción"**, **"Pausar / Reanudar navegación"**, **"Necesito ayuda"** (ofrece llamar al contacto de emergencia configurado) y **"Finalizar ruta"** con confirmación.
- Aviso de proximidad verbal opcional cuando se entra al radio configurado (10 m por defecto) con señal GPS confiable.

---

## 🏗️ Arquitectura y Estructura del Código

```
lib/
├── main.dart                               # Inicialización de servicios y MultiProvider
├── app.dart                                # MaterialApp, temas accesibles y shell de 4 pestañas
├── core/
│   ├── constants.dart                      # Constantes de umbrales GPS, duraciones, colores y enums
│   ├── theme.dart                          # Temas claro y oscuro (Atkinson Hyperlegible, WCAG AA/AAA)
│   ├── strings.dart                        # Textos y locuciones de interfaz centralizados en español
│   └── utils/
│       ├── geo_utils.dart                  # Haversine, cálculo de distancias y formateo accesible
│       └── date_utils.dart                 # Fechas legibles en español y regla de caducidad (>30 días)
├── data/
│   ├── models/
│   │   ├── route_model.dart                # Modelo de Ruta (JSON/Map, cálculo de caducidad)
│   │   ├── waypoint_model.dart             # Modelo de Punto de Control
│   │   ├── capture_model.dart              # Modelo de Captura y Lecturas GPS
│   │   └── warning_model.dart              # Modelo de Advertencia manual por punto
│   └── repositories/
│       ├── route_repository.dart           # Interfaz abstracta para persistencia
│       └── local_json_route_repository.dart# Implementación local en archivos JSON con path_provider
├── services/
│   ├── stabilization.dart                  # Algoritmo de estabilización GPS en Dart puro
│   ├── location_service.dart               # Geolocator, permisos, stream y captura por fases
│   ├── tts_service.dart                    # Síntesis de voz (es-PE con respaldo es-ES / es-MX)
│   └── settings_service.dart               # Preferencias con SharedPreferences (tema, escala, etc.)
├── features/
│   ├── onboarding/screens/                 # Pantalla de bienvenida, aviso legal y prueba de voz
│   ├── home/screens/                       # Inicio con estado de GPS/TTS y accesos rápidos
│   ├── routes/screens/                     # Lista de rutas, buscador, exportación JSON y eliminación
│   ├── record_route/
│   │   ├── screens/record_route_screen.dart# Asistente por pasos para registrar ruta
│   │   └── widgets/
│   │       ├── support_map.dart            # Mapa OpenStreetMap con flutter_map (ajuste manual y offline notice)
│   │       ├── capture_gps_dialog.dart     # Modal de estabilización GPS por fases
│   │       └── add_warning_dialog.dart     # Diálogo para advertencias manuales
│   ├── navigation/screens/                 # Seguir ruta (alto contraste, panel central, botones grandes)
│   ├── alerts/screens/                     # Diagnóstico de GPS, permisos y rutas desactualizadas
│   └── settings/screens/                   # Ajustes accesibles, sensores y botón "Crear ruta de prueba"
└── widgets/                                # Componentes reutilizables accesibles
    ├── accessible_button.dart              # Botón táctil >= 48dp con Semantics y alto contraste
    ├── accessible_dialog.dart              # Confirmación modal accesible para acciones destructivas
    ├── gps_indicator.dart                  # Indicador accesible de estado y precisión GPS
    ├── instruction_panel.dart              # Panel de instrucción activa de alto contraste
    ├── status_badge.dart                   # Insignias con icono y texto (estado, prueba, calidad)
    └── warning_card.dart                   # Tarjeta accesible para mostrar advertencias con fecha
```

---

## 📐 Algoritmo de Estabilización GPS (`stabilization.dart`)

Ubicado en una clase pura de Dart sin dependencias de Flutter para permitir pruebas unitarias deterministas:
1. **Filtro de precisión bruta**: Se descartan lecturas con precisión reportada mayor a **50.0 m** (`gpsMaxDiscardAccuracyMeters`).
2. **Mediana geográfica**: Se calcula la mediana de latitud y longitud como centro preliminar resistente a valores atípicos.
3. **Filtrado de outliers (3x Mediana)**: Se calculan las distancias de cada lectura al centro preliminar. Se descartan aquellas cuya distancia supera **3.0 veces la distancia mediana** (`gpsMedianDistanceMultiplier`).
4. **Recálculo de centro**: Se calcula el centro definitivo a partir de las lecturas válidas resultantes.
5. **Dispersión cuadrática media**: Se calcula la raíz media cuadrática (RMS) de las distancias en metros de las lecturas al centro definitivo:
   $$\text{Dispersión} = \sqrt{\frac{1}{N} \sum_{i=1}^N d_i^2}$$
6. **Precisión media reportada**: Promedio aritmético de los valores `precisionM`.
7. **Criterios de calidad**:
   - **Buena**: Dispersión $\le 5.0\text{ m}$, precisión media $\le 10.0\text{ m}$ y al menos $8$ lecturas válidas.
   - **Regular**: Dispersión $\le 15.0\text{ m}$ y precisión media $\le 25.0\text{ m}$.
   - **Insuficiente**: En cualquier otro caso. Se sugiere repetir la captura.

---

## ⚙️ Umbrales a Calibrar con Datos Reales en Campus UNCP

Todas las constantes se encuentran centralizadas en `lib/core/constants.dart`:
- `gpsMaxDiscardAccuracyMeters`: Actualmente en `50.0 m`. Ajustar según la densidad arbórea o interferencia de edificios en Ciudad Universitaria UNCP.
- `qualityGoodMaxDispersionMeters` (`5.0 m`) y `qualityGoodMaxAvgAccuracyMeters` (`10.0 m`): Calibrar según pruebas de campo en días despejados vs. nublados en Huancayo (~3,250 m s.n.m.).
- `defaultProximityRadiusMeters`: Actualmente en `10.0 m`. Rango ajustable en Ajustes entre `5 m` y `20 m`.
- `routeOutdatedDays`: Actualmente en `30` días. Período tras el cual una ruta pasa automáticamente a estado *Desactualizada*.

---

## 🚀 Cómo Ejecutar el Proyecto

### Requisitos
- Flutter SDK (versión 3.16 o superior).
- Android SDK (minSdkVersion 24).
- Dispositivo Android físico o emulador con Google Play Services.

### Pasos
1. Obtener dependencias:
   ```bash
   flutter pub get
   ```
2. Ejecutar pruebas automatizadas:
   ```bash
   flutter test
   ```
3. Ejecutar análisis de código:
   ```bash
   flutter analyze
   ```
4. Lanzar la aplicación en dispositivo Android:
   ```bash
   flutter run
   ```

---

## 🧪 Pruebas Automatizadas Incluidas

El proyecto cuenta con 20 pruebas automáticas en `test/`:
- `test/unit/stabilization_test.dart`: Algoritmo de estabilización (casos vacíos, rechazo por precisión > 50 m, clasificación de calidad y filtrado de valores atípicos severos).
- `test/unit/models_serialization_test.dart`: Serialización y deserialización JSON completa de rutas, puntos, capturas y advertencias, incluyendo soporte de coordenadas nulas.
- `test/unit/geo_utils_test.dart`: Cálculo de distancia Haversine y formateo accesible de distancias y precisión.
- `test/unit/route_expiration_test.dart`: Regla automática de caducidad tras 30 días sin revisión.
- `test/widget/semantics_test.dart`: Comprobación de etiquetas `Semantics`, contrastes y dimensiones táctiles mínimas $\ge 48\times 48\text{ dp}$.
- `test/widget_test.dart`: Prueba de arranque general del árbol de widgets (`NaviunApp`).

---

## 📦 Decisiones de Diseño y Limitaciones Conocidas

- **Tipografía**: Atkinson Hyperlegible (OFL) incluida localmente en `assets/fonts/` para garantizar legibilidad y funcionamiento 100% offline.
- **Sin backend**: La persistencia es local e individual por archivo JSON (`path_provider`), detrás de la abstracción `RouteRepository`, permitiendo migrar fácilmente a SQLite (`sqflite`) en futuras fases.
- **Exportación**: Uso de `share_plus` para compartir directamente el archivo o texto JSON de la ruta con otros dispositivos.
- **Ruta de prueba**: Se incluye en Inicio y en Ajustes la opción "Crear ruta de prueba", la cual genera una ruta marcada como "DATOS DE PRUEBA" sin coordenadas GPS para permitir la demostración y verificación de los flujos de voz y avance táctil en interiores sin necesidad de salir al campus.
- **Sensores no incluidos**: Conforme a las especificaciones del MVP, no se implementó fusión de sensores ni detección por visión artificial. En Ajustes se muestra el estado del GPS y para el resto la leyenda *"No incluido en esta versión"*.

---

## 🔮 Integración Futura de Sensores y Mejoras

1. **Fusión de Sensores (IMU)**: Integrar acelerómetro y giroscopio (`sensors_plus`) con filtros de Kalman o complementarios para dead reckoning peatonal en pasillos techados donde la señal GPS se pierde.
2. **Balizas BLE y NFC**: Detección de proximidad en interiores (laboratorios, aulas) mediante balizas Bluetooth o tags NFC en marcos de puertas.
3. **Backend y Sincronización**: Repositorio centralizado en campus UNCP para validación colaborativa de rutas por parte del personal de orientación y bienestar universitario.
4. **Dictado por voz**: Integración de `speech_to_text` en el asistente de creación para redactar instrucciones por dictado.

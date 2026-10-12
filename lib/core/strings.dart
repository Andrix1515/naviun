/// Textos centralizados de la interfaz y locuciones de voz de Naviun (en español).
class AppStrings {
  AppStrings._();

  // Nombre y lema
  static const String appName = 'Naviun';
  static const String appSlogan = 'Tu guía en la universidad';
  static const String universityName = 'Universidad Nacional del Centro del Perú (UNCP)';

  // Seguridad
  static const String safetyWarningTitle = 'Aviso importante de seguridad';
  static const String safetyWarningBody =
      'Las rutas registradas son observaciones de un momento concreto y pueden cambiar; '
      'la app no sustituye al bastón, al perro guía ni a las técnicas de orientación y movilidad.';
  static const String safetyUnderstand = 'Entendido, continuar';
  static const String testDataBadge = 'DATOS DE PRUEBA';

  // Locuciones de seguridad de voz
  static const String speechGpsUnreliable =
      'No puedo determinar tu ubicación con suficiente confianza. '
      'Detente en un lugar seguro y solicita ayuda si la necesitas.';
  static const String speechNeedHelp =
      'Detente en un lugar seguro y pide ayuda a una persona cercana.';
  static const String speechRouteFinished =
      'Has llegado al punto final de la ruta.';

  // Barra de navegación inferior
  static const String navHome = 'Inicio';
  static const String navRoutes = 'Rutas';
  static const String navAlerts = 'Alertas';
  static const String navSettings = 'Ajustes';

  // Pantalla de Bienvenida / Onboarding
  static const String welcomeTitle = 'Bienvenido a Naviun';
  static const String welcomeSubtitle = 'Navegación accesible en el campus UNCP';
  static const String welcomeStart = 'Comenzar';
  static const String welcomeSkip = 'Omitir configuración';
  static const String welcomeTextSizeTitle = 'Tamaño de texto';
  static const String welcomeThemeTitle = 'Tema visual';
  static const String welcomeVoiceTitle = 'Velocidad de voz';
  static const String testVoiceButton = 'Probar voz';
  static const String testVoicePhrase =
      'Hola, esta es la voz de Naviun para guiarte en el campus de la universidad.';

  // Inicio (HomeScreen)
  static const String homeGreeting = 'Hola, ¿a dónde deseas ir hoy?';
  static const String homeStatusTitle = 'Estado del sistema';
  static const String homeStartNavigation = 'Iniciar navegación';
  static const String homeSearchRoute = 'Buscar ruta';
  static const String homeRecordRoute = 'Registrar ruta';
  static const String homeViewAlerts = 'Ver alertas';
  static const String homeViewSettings = 'Ajustes';
  static const String homeNoRoutesTitle = 'Todavía no hay rutas disponibles';
  static const String homeNoRoutesSubtitle =
      'Puedes registrar una nueva ruta con apoyo de una persona o cargar una ruta de prueba.';
  static const String homeCreateTestRoute = 'Crear ruta de prueba';

  // Rutas (RouteListScreen)
  static const String routesTitle = 'Rutas del campus';
  static const String routesSearchPlaceholder = 'Buscar por nombre, origen o destino';
  static const String routesEmptySearch = 'No se encontraron rutas con ese término.';
  static const String routeOriginLabel = 'Origen:';
  static const String routeDestinationLabel = 'Destino:';
  static const String routeWaypointsCount = 'Puntos de control:';
  static const String routeLastReview = 'Última revisión:';
  static const String routeStartButton = 'Iniciar ruta';
  static const String routeOptionsButton = 'Opciones de ruta';
  static const String routeEdit = 'Editar ruta';
  static const String routeExport = 'Exportar JSON';
  static const String routeDelete = 'Eliminar ruta';
  static const String routeDeleteConfirmTitle = '¿Eliminar esta ruta?';
  static const String routeDeleteConfirmMessage =
      'Esta acción no se puede deshacer. La ruta se borrará de tu dispositivo.';
  static const String routeExportSuccess = 'Ruta exportada correctamente.';
  static const String routeDeleteSuccess = 'Ruta eliminada.';

  // Estados de ruta
  static const String statusDraft = 'Borrador';
  static const String statusPendingValidation = 'Pendiente de validación';
  static const String statusVerified = 'Verificada';
  static const String statusOutdated = 'Desactualizada';

  // Registrar Ruta (RecordRouteScreen)
  static const String recordTitle = 'Registrar nueva ruta';
  static const String recordStepInfo = 'Información general';
  static const String recordStepPoints = 'Puntos de control';
  static const String recordStepReview = 'Revisión final';

  static const String routeNameField = 'Nombre de la ruta';
  static const String routeNameHint = 'Ej: Entrada principal a Facultad de Sistemas';
  static const String routeOriginField = 'Punto de origen';
  static const String routeOriginHint = 'Ej: Puerta 1 - Av. Mariscal Castilla';
  static const String routeDestinationField = 'Punto de destino';
  static const String routeDestinationHint = 'Ej: Pabellón de Ingeniería de Sistemas';

  static const String addWaypointButton = 'Agregar punto de control';
  static const String editWaypointButton = 'Editar punto';
  static const String deleteWaypointButton = 'Eliminar punto';
  static const String reorderWaypointUp = 'Mover hacia arriba';
  static const String reorderWaypointDown = 'Mover hacia abajo';

  // Captura de Punto
  static const String pointNameField = 'Nombre del punto';
  static const String pointNameHint = 'Ej: Escalera de acceso, Giro a la derecha';
  static const String pointTypeField = 'Tipo de punto';
  static const String pointInstructionField = 'Instrucción de voz para este tramo';
  static const String pointInstructionHint =
      'Ej: Camina derecho 15 metros siguiendo la línea guía táctil hasta encontrar la puerta doble.';
  static const String listenInstructionButton = 'Escuchar instrucción';
  static const String stabilizationDurationLabel = 'Duración de estabilización GPS:';
  static const String stabilizationSecondsUnit = 'segundos';
  static const String startCaptureButton = 'Iniciar captura GPS';
  static const String capturingGpsTitle = 'Capturando lecturas GPS...';
  static const String capturingGpsSubtitle =
      'Permanece quieto en la posición exacta del punto de control.';
  static const String captureFinishedTitle = 'Captura finalizada';
  static const String captureValidReadings = 'Lecturas válidas:';
  static const String captureAvgAccuracy = 'Precisión media reportada:';
  static const String captureDispersion = 'Dispersión estimada:';
  static const String captureQuality = 'Calidad:';
  static const String captureConfirm = 'Confirmar punto';
  static const String captureRetry = 'Repetir captura';
  static const String captureDiscard = 'Descartar captura';
  static const String captureSaveWithoutGps = 'Guardar sin GPS (Manual)';
  static const String captureQualityInsufficientWarning =
      'La calidad de la señal GPS es insuficiente. Se recomienda repetir la captura en un lugar más despejado. Puedes guardarla igualmente si es necesario.';

  // Calidad GPS
  static const String qualityGood = 'Buena';
  static const String qualityRegular = 'Regular';
  static const String qualityInsufficient = 'Insuficiente';
  static const String qualityNoCapture = 'Sin captura GPS';

  // Tipos de punto
  static const String typeStart = 'Inicio';
  static const String typePath = 'Pasillo o camino';
  static const String typeTurn = 'Giro o bifurcación';
  static const String typeDoor = 'Puerta o acceso';
  static const String typeStairs = 'Escalera';
  static const String typeDestination = 'Destino';

  // Advertencias por punto
  static const String warningsTitle = 'Advertencias del tramo';
  static const String addWarningButton = 'Agregar advertencia manual';
  static const String warningTypeField = 'Tipo de advertencia';
  static const String warningNoteField = 'Nota o descripción de la advertencia';
  static const String warningNoteHint = 'Ej: Primer escalón con desnivel pronunciado a la izquierda';
  static const String warningDateObservedField = 'Fecha de observación';
  static const String warningTemporaryField = 'Es un obstáculo temporal';
  static const String warningTemporaryBadge = 'TEMPORAL';

  // Tipos de advertencia
  static const String warnStairs = 'Escalera';
  static const String warnRamp = 'Rampa';
  static const String warnCurb = 'Bordillo o desnivel';
  static const String warnUnevenSurface = 'Superficie irregular';
  static const String warnDoor = 'Puerta o acceso';
  static const String warnTemporaryObstacle = 'Obstáculo temporal';
  static const String warnOther = 'Otra advertencia';

  // Mapa de apoyo
  static const String mapTitle = 'Mapa de apoyo visual';
  static const String mapHelpText =
      'Usa el mapa como apoyo visual. Puedes tocar o arrastrar para ajustar la posición si lo requieres.';
  static const String mapAdjustedManualBadge = 'Posición ajustada manualmente';
  static const String mapOfflineNotice =
      'Sin conexión a internet: El mapa base no está disponible, pero la captura GPS y el registro continúan funcionando normalmente.';
  static const String mapCenterOnUser = 'Centrar en mi ubicación';
  static const String mapCenterOnRoute = 'Centrar en la ruta';

  // Guardado de ruta
  static const String saveAsDraft = 'Guardar como Borrador';
  static const String saveAsPendingValidation = 'Guardar como Pendiente de validación';
  static const String routeSavedSuccess = 'Ruta guardada exitosamente.';

  // Seguir Ruta (NavigationScreen)
  static const String navigationTitle = 'Navegación activa';
  static const String navPointProgress = 'Punto {current} de {total}';
  static const String navNextPointLabel = 'Siguiente objetivo:';
  static const String navCurrentInstructionLabel = 'Instrucción activa:';
  static const String navAccuracyReport = 'Precisión GPS:';
  static const String navApproxDistance = 'Distancia aproximada:';
  static const String btnPointReached = 'Llegué al punto';
  static const String btnRepeatInstruction = 'Repetir instrucción';
  static const String btnPauseNavigation = 'Pausar navegación';
  static const String btnResumeNavigation = 'Reanudar navegación';
  static const String btnNeedHelp = 'Necesito ayuda';
  static const String btnExitNavigation = 'Finalizar ruta';
  static const String exitNavConfirmTitle = '¿Deseas finalizar la navegación?';
  static const String exitNavConfirmMessage =
      'Se detendrá el guiado de esta ruta y regresarás al inicio.';
  static const String navigationPausedTitle = 'Navegación pausada';
  static const String navigationPausedMessage =
      'La guía por voz está en pausa. Presiona "Reanudar navegación" cuando estés listo.';
  static const String proximityNotice =
      'Estás cerca de {point}. Confirma cuando llegues.';
  static const String speechWarningPrefix =
      'Advertencia registrada el {date}: {type}. {note}. Verifica el entorno.';

  // Alertas (AlertsScreen)
  static const String alertsTitle = 'Alertas del sistema';
  static const String alertsEmpty = 'No hay alertas activas en este momento.';
  static const String alertGpsDisabledTitle = 'GPS desactivado';
  static const String alertGpsDisabledBody =
      'El servicio de ubicación del dispositivo está apagado. Actívalo para capturar o verificar posiciones.';
  static const String alertGpsDisabledAction = 'Abrir configuración de ubicación';

  static const String alertPermissionDeniedTitle = 'Permiso de ubicación denegado';
  static const String alertPermissionDeniedBody =
      'Naviun requiere acceso a la ubicación precisa para registrar rutas y reportar precisión.';
  static const String alertPermissionDeniedAction = 'Conceder permiso';

  static const String alertPermissionPermanentTitle = 'Permiso denegado permanentemente';
  static const String alertPermissionPermanentBody =
      'El permiso fue denegado de forma permanente. Debes habilitarlo en los Ajustes de Android.';
  static const String alertPermissionPermanentAction = 'Abrir ajustes del sistema';

  static const String alertAccuracyLowTitle = 'Precisión GPS insuficiente';
  static const String alertAccuracyLowBody =
      'La señal GPS actual es débil o imprecisa. Las distancias no se mostrarán hasta que la señal mejore.';

  static const String alertOutdatedRoutesTitle = 'Rutas desactualizadas detectadas';
  static const String alertOutdatedRoutesBody =
      'Una o más rutas tienen más de 30 días sin revisión en el campus. Se recomienda verificarlas.';

  // Ajustes (SettingsScreen)
  static const String settingsTitle = 'Ajustes de Naviun';
  static const String settingsSectionAccessibility = 'Accesibilidad y visualización';
  static const String settingsSectionVoice = 'Voz y audio';
  static const String settingsSectionNavigation = 'Navegación y seguridad';
  static const String settingsSectionSensors = 'Sensores y permisos';
  static const String settingsSectionData = 'Gestión de datos';
  static const String settingsSectionAbout = 'Acerca de Naviun';

  static const String textSizeNormal = 'Normal';
  static const String textSizeLarge = 'Grande';
  static const String textSizeExtraLarge = 'Muy grande';

  static const String themeSystem = 'Predeterminado del sistema';
  static const String themeLight = 'Modo claro';
  static const String themeDark = 'Modo oscuro';

  static const String voiceEnabledLabel = 'Activar instrucciones por voz';
  static const String voiceRateLabel = 'Velocidad de locución';
  static const String voiceVolumeLabel = 'Volumen de locución';
  static const String vibrationEnabledLabel = 'Vibración táctil al pulsar';

  static const String proximityRadiusLabel = 'Radio de aviso de proximidad';
  static const String emergencyContactLabel = 'Contacto de ayuda rápida';
  static const String emergencyContactHint = 'Número de teléfono (ej: 964123456)';
  static const String emergencyContactCall = 'Llamar al contacto de ayuda';

  static const String sensorGpsLabel = 'GPS / Ubicación satelital';
  static const String sensorNotIncluded = 'No incluido en esta versión';
  static const String sensorAccelerometer = 'Acelerómetro y giroscopio';
  static const String sensorBarometer = 'Barómetro y altitud';
  static const String sensorBeacons = 'Balizas Bluetooth / NFC';
  static const String sensorComputerVision = 'Cámara / Visión artificial';

  static const String createTestRouteButton = 'Crear ruta de prueba';
  static const String testRouteCreatedSuccess =
      'Ruta de prueba creada con éxito. Búscala en "Rutas" con la etiqueta DATOS DE PRUEBA.';

  // Estados generales
  static const String loading = 'Cargando...';
  static const String cancel = 'Cancelar';
  static const String accept = 'Aceptar';
  static const String confirm = 'Confirmar';
  static const String back = 'Volver';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';
  static const String retry = 'Reintentar';
  static const String close = 'Cerrar';
  static const String metersUnit = 'm';
  static const String secondsUnit = 's';
}

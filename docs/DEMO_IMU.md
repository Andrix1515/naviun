# Demostración de movimiento con IMU

## Activar

1. En Ajustes, activa **Estimación por sensores (experimental)**.
2. Para reducir el error de distancia, pulsa **Calibrar paso caminando 10 metros**. Mide el tramo con una referencia real, lleva el teléfono como lo llevarás en la prueba y empieza a caminar al iniciar la captura.
3. Durante una ruta, desplázate hasta **Estimación IMU · experimental**. La pantalla muestra los pasos detectados, distancia recorrida aproximada, incertidumbre y rotaciones relativas estimadas.

## Guion de demostración

- Explica que acelerómetro y giroscopio leen el movimiento del teléfono en tiempo real; no son datos pregrabados.
- Camina por un tramo recto y muestra cómo cambian los pasos y la distancia.
- Gira el teléfono para provocar una rotación relativa y mostrar el aviso de orientación estimada.
- Confirma los puntos con el botón manual **Llegué al punto**; la IMU no avanza la ruta.

## Limitaciones que deben mostrarse

- La distancia depende de una calibración de paso y acumula error; la cifra es aproximada y su incertidumbre es orientativa, no una garantía estadística.
- Una rotación del teléfono no demuestra que la persona haya girado ni determina una dirección absoluta. El aviso pide verificar la orientación.
- La demo no proyecta movimiento sobre la geometría de la ruta ni calcula distancia restante hasta un punto; muestra movimiento acumulado del teléfono desde que inició el seguimiento.
- No se detectan ni predicen obstáculos, escaleras, bordes ni caminos libres.
- Esta demo no sustituye el GPS, las instrucciones registradas, el bastón, el perro guía ni las técnicas de orientación y movilidad.
- Los resultados dependen de la posición del teléfono, el motor/sensores y la forma de caminar. Debe probarse con el dispositivo que se usará en la presentación.

La función está apagada por defecto. Al salir de navegación, pausar la app o pausar la ruta, se detienen los flujos de sensores. No se incluyen lecturas simuladas en la app; la señal sintética de 1.8 Hz existe únicamente en una prueba automatizada del procesador.

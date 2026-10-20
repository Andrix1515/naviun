# Guion de demostración con TalkBack

## Flujo A→B completo sin mirar la pantalla

### 1. Abrir la app
- La app debe anunciar el título principal y pasar el foco al inicio.
- Si se abre la pantalla de bienvenida, el lector debe leer el texto legal y la acción principal.

### 2. Elegir destino por voz
- En la pantalla principal, el usuario activa el botón **Escuchar comando**.
- Se oye una señal breve y el sistema espera la palabra clave, por ejemplo: "ir a aula magna".
- La app confirma: "¿Quieres ir a Aula Magna? Di sí o no."

### 3. Confirmar inicio de ruta
- El usuario confirma con voz o toque manual.
- Debe oírse la locución de inicio y el primer punto de la ruta.
- La navegación activa debe anunciar advertencias registradas antes de la instrucción.

### 4. Confirmación de avance
- Al llegar a cada punto, la app anuncia el siguiente punto y la instrucción.
- El usuario pulsa **Llegué al punto** o dicta la confirmación por voz.
- Si el GPS es poco fiable, se debe escuchar el aviso de seguridad y la navegación debe detenerse.

### 5. Finalización
- El usuario confirma la llegada final.
- La app anuncia la finalización y el flujo termina sin depender de la vista.

## Qué debe sentirse en cada paso

- Vibración de confirmación al pulsar un control.
- Vibración de advertencia cuando hay un riesgo o un punto próximo.
- Vibración de fin de ruta al llegar al objetivo.
- Si algo falla, debe escucharse un mensaje claro y una instrucción concreta para repetir o reintentar.

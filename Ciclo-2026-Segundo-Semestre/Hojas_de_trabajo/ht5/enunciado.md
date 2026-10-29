# Enunciado - Hoja de Trabajo 5

## Contexto

La universidad `USAC Analytics Lab` desea analizar permanencia estudiantil usando BigQuery. El problema debe resolverse con enfoque de gobierno de datos y analítica en nube.

Los datos incluyen información sensible como correo institucional, teléfono y carrera. No todos los usuarios deberían ver toda la información.

## Instrucciones

Trabaja en BigQuery y desarrolla lo siguiente:

1. Crea las tablas base a partir de los archivos entregados.
2. Identifica al menos 2 columnas sensibles y explica cómo las protegerías.
3. Crea una vista para usuarios de negocio que no exponga correo ni teléfono.
4. Crea una política de acceso por fila o describe cómo la aplicarías por facultad.
5. Escribe una consulta poco eficiente y luego una versión optimizada.
6. Crea una vista materializada con indicadores útiles para seguimiento estudiantil.

## Tablas

### estudiantes

- datos generales del estudiante;
- incluye indicadores académicos y administrativos útiles para análisis.

### pagos

- pagos mensuales o atrasos;
- puede ayudar a inferir comportamiento financiero.

### actividad_virtual

- sesiones y actividad en plataforma virtual;
- puede ayudar a inferir compromiso académico.

## Preguntas de análisis

Responde en tu entrega:

1. ¿Qué columnas protegerías con seguridad a nivel de columna?
2. ¿Qué usuario debería ver la tabla completa y cuál solo una vista?
3. ¿Qué mejora concreta aplicaste para optimizar una consulta?
4. ¿Qué indicadores incluye la vista materializada y por qué son útiles?

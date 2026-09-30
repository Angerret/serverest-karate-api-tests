# Informe de estrategia de automatización – API de Usuarios (ServeRest)

## 1. Enfoque general

Se automatizó el recurso `/usuarios` de ServeRest con **Karate DSL**, un framework que integra en una sola herramienta el cliente HTTP, las aserciones, la validación de esquemas JSON, la ejecución en paralelo y los reportes. Su sintaxis Gherkin hace que cada escenario sea legible como una especificación funcional.

Cada criterio de aceptación de la historia de usuario se tradujo en escenarios **positivos** (el comportamiento esperado) y **negativos** (validaciones y errores de negocio), y cada operación se verifica de punta a punta. Por ejemplo, después de un POST o un PUT se consulta el recurso para confirmar que los datos quedaron realmente guardados, y después de un DELETE se confirma que el usuario ya no existe.

## 2. Organización del proyecto

- **Un feature por endpoint** (`usuarios/`), tal como pide la especificación, más un feature de flujo CRUD completo.
- **Features reutilizables** (`common/`, marcados con `@ignore`) para las precondiciones: crear un usuario, iniciar sesión y eliminar un usuario. Se invocan con `call`, lo que evita duplicar pasos.
- **Configuración centralizada** (`karate-config.js`): la URL por ambiente (`dev` o `local`), los esquemas y los mensajes esperados se cargan una sola vez y quedan disponibles para todos los features.
- **Tags** por endpoint, por tipo de caso y por criticidad (`@smoke`), para ejecutar subconjuntos según la necesidad.

## 3. Patrones aplicados

| Patrón | Implementación |
|---|---|
| **Reutilización por llamada (call)** | `crear-usuario`, `login` y `eliminar-usuario` actúan como "servicios" que otros escenarios invocan |
| **Data Builder / generador de datos** | `DataGenerator.java` construye payloads válidos y únicos (email con UUID, ID inexistente, producto) |
| **Data-Driven Testing** | `Scenario Outline` con tablas `Examples` y con datos externos (`data/usuarios-invalidos.json`) |
| **Esquemas como contrato** | Archivos en `schemas/` reutilizados en todas las validaciones; el esquema de la lista reutiliza el del usuario (`#[] usuarioSchema`) |
| **Setup / Teardown** | Precondiciones en `Background` y limpieza automática en el hook `afterScenario` |
| **Externalización de datos** | Mensajes esperados en `data/mensajes.json`, sin textos repetidos en los features |

## 4. Validación de respuestas y esquemas JSON

Cada respuesta se valida en tres niveles:

1. **Código de estado HTTP** (`200`, `201`, `400`).
2. **Esquema/contrato** con los *fuzzy matchers* de Karate: tipos (`#string`, `#number`), expresiones regulares para el formato de `_id` (16 caracteres alfanuméricos), `email` y `administrador` (`true|false`), y validación de cada elemento del arreglo (`#[]`). La comparación con `==` también garantiza que no aparezcan campos inesperados.
3. **Contenido**: mensajes de negocio exactos y datos persistidos iguales a los enviados (`karate.merge(payload, { _id })`).

## 5. Manejo de datos de prueba

- **Datos dinámicos y únicos:** la API pública es compartida por muchas personas, así que cada escenario genera sus propios datos (email con UUID). Esto evita colisiones y permite ejecutar en paralelo.
- **Independencia:** ningún escenario depende de datos preexistentes ni del orden de ejecución; cada uno crea lo que necesita.
- **Limpieza automática:** los IDs creados se registran en `idsParaLimpiar` y el hook `afterScenario` los elimina **aunque el escenario falle**, así no queda basura en la API.
- **Datos negativos externos:** los casos inválidos viven en un JSON, de modo que agregar un caso nuevo no requiere tocar el código.

## 6. Ejecución y CI

- El runner JUnit 5 ejecuta la suite **en paralelo** (5 hilos por defecto, configurable con `-Dthreads`).
- El pipeline de **GitHub Actions** corre en cada push o pull request y publica el reporte HTML como artefacto. También permite ejecutarla manualmente contra una instancia **local** de ServeRest levantada en el propio runner, lo que la aísla de la disponibilidad de la API pública.

## 7. Consideraciones y mejoras futuras

- ServeRest devuelve algunos códigos poco convencionales (por ejemplo, `400` para un recurso no encontrado, o `201` cuando se hace PUT sobre un ID inexistente). Las pruebas validan el **comportamiento documentado** de la API y lo dejan explícito en los escenarios.
- Posibles mejoras: extender la cobertura a `/login`, `/produtos` y `/carrinhos`; incorporar pruebas de rendimiento reutilizando los features con Gatling (integración nativa de Karate); y generar reportes enriquecidos con Allure.

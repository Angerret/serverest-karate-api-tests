# ServeRest – Automatización de la API de Usuarios con Karate DSL

Suite de pruebas automatizadas para el recurso **/usuarios** de la API [ServeRest](https://serverest.dev/), construida con **Karate DSL**, **Java 17**, **Maven** y **JUnit 5**.

## Tecnologías

| Herramienta | Uso |
|---|---|
| [Karate DSL](https://github.com/karatelabs/karate) 1.5.x | Pruebas de API, validación de esquemas JSON y reportes |
| Java 17 (JDK) | Runtime y generador de datos de prueba |
| Maven 3.9+ | Gestión de dependencias y ejecución |
| JUnit 5 | Runner de la suite (ejecución en paralelo) |
| GitHub Actions | Integración continua |

## Requisitos previos

- **JDK 17** o superior (`java -version`)
- **Maven 3.9** o superior (`mvn -v`)
- **Git**
- Opcional: **Node.js**, para levantar ServeRest en local

## Instalación

```bash
git clone https://github.com/<tu-usuario>/serverest-karate-api-tests.git
cd serverest-karate-api-tests
mvn clean test-compile
```

## Ejecución

| Comando | Descripción |
|---|---|
| `mvn clean test` | Toda la suite contra `https://serverest.dev` |
| `mvn clean test -Dkarate.options="--tags @smoke"` | Solo escenarios críticos |
| `mvn clean test -Dkarate.options="--tags @negativo"` | Solo escenarios negativos |
| `mvn clean test -Dkarate.options="--tags @registrar"` | Solo un endpoint (`@listar`, `@registrar`, `@buscar`, `@actualizar`, `@eliminar`, `@e2e`) |
| `mvn clean test -Dkarate.options="classpath:usuarios/buscar-usuario.feature"` | Un feature específico |
| `mvn clean test -Dkarate.env=local` | Contra ServeRest local (`http://localhost:3000`) |
| `mvn clean test -Dthreads=1` | En secuencia (útil para depurar) |

> **Windows (PowerShell):** encierra entre comillas todo el parámetro `-D`, por ejemplo `mvn clean test "-Dkarate.options=--tags @smoke"`.

### Ejecutar contra ServeRest local (opcional)

Si la API pública está lenta o no disponible:

```bash
# Terminal 1: levantar ServeRest
npx serverest@latest

# Terminal 2: ejecutar las pruebas
mvn clean test -Dkarate.env=local
```

## Reportes

Al terminar la ejecución:

- `target/karate-reports/karate-summary.html`: reporte principal, con el detalle de cada request y response.
- `target/karate-reports/*.json`: reportes en formato Cucumber JSON.
- `target/karate.log`: log completo.

## Estructura del proyecto

```
src/test/java/
├── karate-config.js              # Ambientes, schemas y mensajes globales
├── logback-test.xml              # Configuración de logs
├── runners/UsuariosTest.java     # Runner JUnit 5 (ejecución en paralelo)
├── helpers/
│   ├── DataGenerator.java        # Generador de datos de prueba dinámicos y únicos
│   └── limpieza.js               # Hook afterScenario: elimina los datos creados
├── common/                       # Features reutilizables (@ignore)
│   ├── crear-usuario.feature
│   ├── eliminar-usuario.feature
│   └── login.feature
├── usuarios/                     # Un feature por endpoint
│   ├── listar-usuarios.feature       # GET    /usuarios
│   ├── registrar-usuario.feature     # POST   /usuarios
│   ├── buscar-usuario.feature        # GET    /usuarios/{_id}
│   ├── actualizar-usuario.feature    # PUT    /usuarios/{_id}
│   ├── eliminar-usuario.feature      # DELETE /usuarios/{_id}
│   └── flujo-crud-usuario.feature    # Flujo E2E completo
├── schemas/                      # Esquemas JSON de respuesta
└── data/                         # Mensajes esperados y datos inválidos (data-driven)
```

## Cobertura de criterios de aceptación

| # | Criterio | Endpoint | Positivos | Negativos |
|---|---|---|---|---|
| 1 | Listar usuarios | `GET /usuarios` | Lista completa con esquema; filtro por email; filtro por administrador | Email inexistente → lista vacía; filtro inválido → 400 |
| 2 | Registrar usuario | `POST /usuarios` | Administrador y no administrador, verificando la persistencia | Email duplicado; 9 casos de datos inválidos (data-driven) |
| 3 | Buscar por ID | `GET /usuarios/{_id}` | Usuario existente con esquema | ID inexistente; ID con formato inválido |
| 4 | Actualizar usuario | `PUT /usuarios/{_id}` | Actualización verificada; ID inexistente crea un usuario | Email de otro usuario; campos obligatorios faltantes |
| 5 | Eliminar usuario | `DELETE /usuarios/{_id}` | Eliminación verificada | ID inexistente; usuario con carrito |

**Total: 31 escenarios**, incluido un flujo CRUD de punta a punta (`@e2e`).

## Tags

`@usuarios` `@listar` `@registrar` `@buscar` `@actualizar` `@eliminar` `@e2e` `@smoke` `@positivo` `@negativo` `@data-driven` `@carrito`

## Estrategia

La explicación de las decisiones de diseño está en [docs/ESTRATEGIA.md](docs/ESTRATEGIA.md).

# MCP Demo — PostgreSQL + Cursor

Servidor MCP (Model Context Protocol) que conecta un LLM en Cursor con una base de datos PostgreSQL, permitiendo consultar tablas, esquemas y ejecutar queries usando lenguaje natural.

## Arquitectura

```
Cliente MCP (LLM)  ←── MCP Protocol (streamable-http) ──→  Servidor Python (:8000)  ←── psycopg2 (TCP) ──→  PostgreSQL
```

El proyecto tiene 3 capas:

1. **Servidor MCP** — `FastMCP` levanta un servidor HTTP en el puerto 8000 que habla JSON-RPC sobre `streamable-http`. Cualquier cliente MCP compatible puede conectarse por HTTP.
2. **Tools, Resources y Prompts** — Funciones decoradas con `@mcp.tool()`, `@mcp.resource()` y `@mcp.prompt()` que exponen distintas capacidades al LLM (ver detalle abajo).
3. **Conexión a PostgreSQL** — Cada operación abre una conexión TCP a PostgreSQL usando `psycopg2`, ejecuta el SQL y cierra la conexión automáticamente gracias a `@contextmanager`.

## Decoradores MCP

El servidor expone funcionalidad al LLM mediante tres tipos de decoradores. Cada uno cumple un rol distinto dentro del protocolo:

### `@mcp.tool()` — Acciones que el LLM puede ejecutar

Las tools son funciones que el LLM decide invocar para realizar operaciones. El decorador lee el nombre, el docstring y los type hints de la funcion para generar automaticamente un JSON Schema que el cliente MCP usa para saber como llamarla.

| Tool                         | Descripcion                                                      |
| ---------------------------- | ---------------------------------------------------------------- |
| `query(sql)`                 | Ejecuta una consulta SELECT y retorna los resultados como JSON   |
| `list_tables()`              | Lista todas las tablas del schema `public`                       |
| `describe_table(table_name)` | Describe las columnas, tipos de dato y nullabilidad de una tabla |

### `@mcp.resource()` — Datos de solo lectura

Los resources exponen datos estaticos o semi-estaticos que el cliente MCP puede leer directamente, sin que el LLM necesite invocar un tool. Funcionan como endpoints de lectura identificados por una URI.

| Resource                          | URI                          | Descripcion                                    |
| --------------------------------- | ---------------------------- | ---------------------------------------------- |
| `get_schema()`                    | `schema://tables`            | Lista de todas las tablas                       |
| `get_table_schema(table_name)`    | `schema://tables/{table_name}` | Esquema detallado de una tabla especifica    |
| `get_db_stats()`                  | `db://stats`                 | Cantidad de filas por tabla                     |

La diferencia clave con las tools es que los **resources** representan contexto/datos que el modelo puede consultar, mientras que las **tools** representan acciones que el modelo decide ejecutar.

### `@mcp.prompt()` — Plantillas de instrucciones reutilizables

Los prompts son plantillas predefinidas que guian al LLM sobre que tools usar y en que orden. No ejecutan nada por si mismas, solo devuelven texto con instrucciones paso a paso. El cliente puede listarlas y el usuario elige cual ejecutar.

| Prompt                            | Descripcion                                                    |
| --------------------------------- | -------------------------------------------------------------- |
| `analizar_tabla(table_name)`      | Genera un analisis completo de una tabla: estructura y datos   |
| `reporte_resumido()`              | Genera un reporte ejecutivo de toda la base de datos           |

### `@contextmanager` — Gestion automatica de conexiones

Este decorador es de la stdlib de Python (`contextlib`). Convierte una funcion generadora en un context manager compatible con `with`. En este proyecto se usa para abrir y cerrar conexiones a PostgreSQL automaticamente:

```python
@contextmanager
def get_connection():
    conn = psycopg2.connect(**DB_CONFIG)
    try:
        yield conn       # entrega la conexion al bloque with
    finally:
        conn.close()     # siempre cierra la conexion al salir, incluso si hay error
```

Esto permite que cualquier tool use `with get_connection() as conn:` y la conexion se cierre automaticamente, incluso si ocurre una excepcion.

## Requisitos

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (gestor de paquetes)
- PostgreSQL corriendo en localhost (o configurar los datos de conexion en el script)

Estructura interna de una tool (como `@mcp.tool()` genera el schema):

```python
@mcp.tool()
    │
    ├── Lee el nombre de la funcion → "query"
    ├── Lee el docstring → "Ejecuta una consulta SELECT..."
    ├── Lee los type hints → sql: str, return: str
    ├── Genera un JSON Schema automaticamente:
    │   {
    │     "name": "query",
    │     "description": "Ejecuta una consulta SELECT...",
    │     "inputSchema": {
    │       "type": "object",
    │       "properties": {
    │         "sql": { "type": "string" }
    │       },
    │       "required": ["sql"]
    │     }
    │   }
    └── Registra la funcion en el servidor MCP
```

## Instalacion

```bash
# Clonar el repo
git clone <repo-url>
cd mcp-demo

# Instalar dependencias con uv
uv sync
```

Las dependencias principales son:

- `psycopg2-binary` — Driver de PostgreSQL para Python
- `mcp[cli]` — SDK del Model Context Protocol

## Configuracion de la base de datos

Editar los parametros de conexion en `src/mcp/mcp-demo.py`:

```python
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "mcp_demo",
    "user": "admin",
    "password": "admin123"
}
```

## Configuracion en Cursor

El servidor usa transporte `streamable-http`, por lo que se configura con `url` en vez de `command`:

```json
{
  "mcpServers": {
    "mi-postgres": {
      "url": "http://localhost:8000/mcp"
    }
  }
}
```

> **Nota:** Primero hay que levantar el servidor (`uv run python src/mcp/mcp-demo.py`) y luego conectar Cursor. Para desarrollo local tambien se puede usar el modo stdio cambiando el transporte en el script.

## Testing con MCP Inspector

El SDK incluye un inspector visual para probar las tools sin necesidad de Cursor:

```bash
uv run mcp dev src/mcp/mcp-demo.py
```

Esto abre un navegador en `http://localhost:6274` donde se puede:

- Conectarse al servidor
- Ver las tools y resources registradas
- Ejecutar tools manualmente y ver las respuestas

## Flujo de una consulta

```
1. Usuario en Cursor:  "que tablas hay en la base?"
2. El LLM decide llamar la tool  →  list_tables()
3. Cursor envia un POST HTTP al servidor MCP  →  {"method": "tools/call", ...}
4. El servidor ejecuta list_tables()
   → get_connection() abre conexion TCP al puerto 5432
   → ejecuta el SQL contra PostgreSQL
   → devuelve el resultado como JSON
5. El servidor responde por HTTP con el JSON
6. Cursor le pasa el resultado al LLM, que lo muestra formateado
```

## Ejecucion

```bash
# Levantar el servidor MCP (streamable-http en puerto 8000)
uv run python src/mcp/mcp-demo.py

# Testing con MCP Inspector
uv run mcp dev src/mcp/mcp-demo.py

# Exponer el servidor con cloudflared (opcional, para acceso remoto)
cloudflared tunnel --url http://localhost:8000
```

## Estructura del proyecto

```bash
mcp-demo/
├── pyproject.toml          # Dependencias y metadata del proyecto
├── docker-compose.yml      # PostgreSQL + servidor MCP en contenedores
├── init.sql                # Script de inicializacion de la base de datos
├── main.py                 # Entry point basico (hello world)
├── src/
│   └── mcp/
│       └── mcp-demo.py     # Servidor MCP con tools, resources y prompts
└── README.md
```

## Flujo completo de la peticion

```javascript
Usuario: "¿Cuántos empleados hay por departamento?"
    │
    ▼
Claude (LLM): Analiza la pregunta
    │  "Necesito consultar la base de datos"
    │  "Voy a usar el tool 'query'"
    ▼
Claude → MCP Server (JSON-RPC via HTTP POST a :8000/mcp):
    {
      "method": "tools/call",
      "params": {
        "name": "query",
        "arguments": {
          "sql": "SELECT departamento, COUNT(*) as total FROM empleados GROUP BY departamento"
        }
      }
    }
    │
    ▼
MCP Server → PostgreSQL (protocolo libpq via TCP):
    SQL query ejecutado
    │
    ▼
PostgreSQL → MCP Server:
    Filas de resultado
    │
    ▼
MCP Server → Claude (JSON-RPC via HTTP response):
    {
      "result": [
        {"departamento": "Ingeniería", "total": 4},
        {"departamento": "Ventas", "total": 2},
        ...
      ]
    }
    │
    ▼
Claude → Usuario:
    "Hay 4 empleados en Ingeniería, 2 en Ventas,
     2 en Marketing y 2 en Recursos Humanos."
```

# MCP Demo — PostgreSQL + Cursor

Servidor MCP (Model Context Protocol) que conecta un LLM en Cursor con una base de datos PostgreSQL, permitiendo consultar tablas, esquemas y ejecutar queries usando lenguaje natural.

## Arquitectura

```
Cursor (LLM)  ←── MCP Protocol (stdio) ──→  Servidor Python  ←── psycopg2 (TCP) ──→  PostgreSQL
```

El proyecto tiene 3 capas:

1. **Servidor MCP** — `FastMCP` levanta un servidor que habla JSON-RPC sobre stdin/stdout. Cursor lanza el proceso y se comunica con él por esos canales.
2. **Tools** — Funciones decoradas con `@mcp.tool()` que el LLM puede invocar. El LLM lee el nombre y el docstring de cada tool para decidir cuándo usarlas.
3. **Conexión a PostgreSQL** — Cada tool abre una conexión TCP a PostgreSQL usando `psycopg2`, ejecuta el SQL y cierra la conexión.

## Tools disponibles

| Tool                         | Descripcion                                                      |
| ---------------------------- | ---------------------------------------------------------------- |
| `query(sql)`                 | Ejecuta una consulta SELECT y retorna los resultados como JSON   |
| `list_tables()`              | Lista todas las tablas del schema `public`                       |
| `describe_table(table_name)` | Describe las columnas, tipos de dato y nullabilidad de una tabla |

## Requisitos

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (gestor de paquetes)
- PostgreSQL corriendo en localhost (o configurar los datos de conexion en el script)

Estructura de la tool:

```python
@mcp.tool()
    │
    ├── Lee el nombre de la función → "query"
    ├── Lee el docstring → "Ejecuta una consulta SELECT..."
    ├── Lee los type hints → sql: str, return: str
    ├── Genera un JSON Schema automáticamente:
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
    └── Registra la función en el servidor MCP
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

Agregar el servidor en `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "mi-postgres": {
      "command": "uv",
      "args": [
        "run",
        "--directory",
        "/ruta/al/proyecto/mcp-demo",
        "python",
        "src/mcp/mcp-demo.py"
      ]
    }
  }
}
```

> **Importante:** Se usa `uv run` en vez de `python` directamente para que el script se ejecute dentro del entorno virtual donde estan instaladas las dependencias.

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
3. Cursor envia por stdin al proceso Python  →  {"method": "list_tables"}
4. El servidor ejecuta list_tables()
   → get_connection() abre conexion TCP al puerto 5432
   → ejecuta el SQL contra PostgreSQL
   → devuelve el resultado como JSON
5. El servidor responde por stdout con el JSON
6. Cursor le pasa el resultado al LLM, que lo muestra formateado
```

## Estructura del proyecto

```bash
mcp-demo/
├── pyproject.toml          # Dependencias y metadata del proyecto
├── main.py                 # Entry point basico (hello world)
├── src/
│   └── mcp/
│       └── mcp-demo.py     # Servidor MCP con las tools de PostgreSQL
└── README.md
```

## Flujo compleo de la peticion

```javascript
Usuario: "¿Cuántos empleados hay por departamento?"
    │
    ▼
Claude (LLM): Analiza la pregunta
    │  "Necesito consultar la base de datos"
    │  "Voy a usar el tool 'query'"
    ▼
Claude → MCP Server (JSON-RPC via stdio):
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
MCP Server → Claude (JSON-RPC via stdio):
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

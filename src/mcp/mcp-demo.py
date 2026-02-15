# mcp_postgres_server.py
import json
import psycopg2
from contextlib import contextmanager
from mcp.server.fastmcp import FastMCP

# Servidor MCP 
mcp = FastMCP("PostgreSQL MCP Server", host="0.0.0.0", port=8000)

# Configuración de conexión 
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "mcp_demo",
    "user": "admin",
    "password": "admin123",
}

@contextmanager
def get_connection():
    """Context manager que abre y cierra la conexión automáticamente."""
    conn = psycopg2.connect(**DB_CONFIG)
    try:
        yield conn
    finally:
        conn.close()
        
@mcp.tool()
def list_tables() -> str:
    """Lista todas las tablas disponibles en el schema public."""
    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
            ORDER BY table_name
        """)
        tables = [row[0] for row in cur.fetchall()]
        return json.dumps(tables, indent=2)

@mcp.tool()
def describe_table(table_name: str) -> str:
    """Describe las columnas de una tabla: nombre, tipo de dato y si acepta nulos."""
    with get_connection() as conn:
        cur = conn.cursor()
        # Verificar que la tabla existe
        cur.execute(
            "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = %s",
            (table_name,),
        )
        if cur.fetchone() is None:
            return json.dumps({"error": f"La tabla '{table_name}' no existe. Usa list_tables para ver las tablas disponibles."})

        cur.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = %s
            ORDER BY ordinal_position
        """, (table_name,))
        result = [
            {"column": c[0], "type": c[1], "nullable": c[2]}
            for c in cur.fetchall()
        ]
        return json.dumps(result, indent=2)

@mcp.tool()
def query(sql: str) -> str:
    """Ejecuta una consulta SELECT (solo lectura) y retorna los resultados como JSON."""
    sql_stripped = sql.strip().rstrip(";").upper()
    if not sql_stripped.startswith("SELECT") and not sql_stripped.startswith("WITH"):
        return json.dumps({"error": "Este tool solo permite consultas SELECT. Usa execute_sql para INSERT/UPDATE/DELETE."})

    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute(sql)
        columns = [desc[0] for desc in cur.description]
        rows = cur.fetchall()
        result = [dict(zip(columns, row)) for row in rows]
        return json.dumps(result, default=str, indent=2)

# @mcp.tool()
# def execute_sql(sql: str) -> str:
#     """Ejecuta INSERT, UPDATE o DELETE y retorna la cantidad de filas afectadas."""
#     sql_upper = sql.strip().rstrip(";").upper()
#     if sql_upper.startswith("SELECT"):
#         return json.dumps({"error": "Para consultas SELECT usa el tool 'query'."})
#     if sql_upper.startswith("DROP") or sql_upper.startswith("TRUNCATE"):
#         return json.dumps({"error": "Operaciones DROP/TRUNCATE no están permitidas por seguridad."})

#     with get_connection() as conn:
#         cur = conn.cursor()
#         cur.execute(sql)
#         conn.commit()
#         return json.dumps({
#             "status": "ok",
#             "filas_afectadas": cur.rowcount,
#         })

@mcp.resource("schema://tables")
def get_schema() -> str:
    """Retorna la lista de todas las tablas de la base de datos."""
    return list_tables()

@mcp.resource("schema://tables/{table_name}")
def get_table_schema(table_name: str) -> str:
    """Retorna el esquema detallado de una tabla específica."""
    return describe_table(table_name)

@mcp.resource("db://stats")
def get_db_stats() -> str:
    """Retorna estadísticas generales: cantidad de filas por tabla."""
    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
            ORDER BY table_name
        """)
        tables = [row[0] for row in cur.fetchall()]

        stats = {}
        for table in tables:
            cur.execute(f"SELECT COUNT(*) FROM {table}")  # noqa: S608
            stats[table] = cur.fetchone()[0]

        return json.dumps(stats, indent=2)

@mcp.prompt()
def analizar_tabla(table_name: str) -> str:
    """Genera un análisis completo de una tabla: estructura, datos y patrones."""
    return f"""Analiza la tabla '{table_name}' de la base de datos siguiendo estos pasos:

1. Usa `describe_table` para ver la estructura de la tabla.
2. Usa `query` para obtener las primeras 10 filas: SELECT * FROM {table_name} LIMIT 10
3. Usa `query` para obtener estadísticas básicas (conteo, promedios si hay columnas numéricas).
4. Presenta un resumen con:
   - Descripción de la tabla y sus columnas
   - Cantidad total de registros
   - Observaciones o patrones interesantes en los datos"""

@mcp.prompt()
def reporte_resumido() -> str:
    """Genera un reporte ejecutivo de toda la base de datos."""
    return """Genera un reporte resumido de la base de datos completa:

1. Usa `list_tables` para ver todas las tablas disponibles.
2. Para cada tabla, usa `describe_table` para ver su estructura.
3. Usa `query` para obtener el conteo de registros de cada tabla.
4. Identifica las relaciones entre tablas (foreign keys).
5. Presenta un resumen ejecutivo con:
   - Diagrama de las tablas y sus relaciones
   - Cantidad de registros por tabla
   - Observaciones generales sobre el modelo de datos"""

# Iniciar el servidor
if __name__ == "__main__":
    # mcp.run()  # stdio (para Cursor/Claude Code)
    mcp.run(transport="streamable-http")

# uv run mcp dev src/mcp/mcp-demo.py
# uv run python src/mcp/mcp-demo.py
# cloudflared tunnel --url http://localhost:8000
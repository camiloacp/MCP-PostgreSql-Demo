# mcp_postgres_server.py
import json
import psycopg2
from mcp.server.fastmcp import FastMCP

# Instancia el servidor
mcp = FastMCP("PostgreSQL MCP Server", host="0.0.0.0", port=8000)

# Configuración de conexión
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "mcp_demo",
    "user": "admin",
    "password": "admin123"
}

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

 # Tools
@mcp.tool()
def query(sql: str) -> str:
    """Ejecuta una consulta SELECT en la base de datos PostgreSQL."""
    conn = get_connection()                              # 1. Abrir conexión
    try:
        cur = conn.cursor()                              # 2. Crear cursor
        cur.execute(sql)                                 # 3. Ejecutar SQL
        columns = [desc[0] for desc in cur.description]  # 4. Nombres de columnas
        rows = cur.fetchall()                            # 5. Obtener filas
        result = [dict(zip(columns, row)) for row in rows]  # 6. Combinar
        return json.dumps(result, default=str, indent=2) # 7. Serializar
    finally:
        conn.close()                                     # 8. SIEMPRE cerrar la conexión


@mcp.tool()
def list_tables() -> str:
    """Lista todas las tablas disponibles en la base de datos."""
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """)
        tables = [row[0] for row in cur.fetchall()]
        return json.dumps(tables, indent=2)
    finally:
        conn.close()


@mcp.tool()
def describe_table(table_name: str) -> str:
    """Describe las columnas de una tabla específica."""
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = %s
            ORDER BY ordinal_position
        """, (table_name,))
        columns = cur.fetchall()
        result = [
            {"column": c[0], "type": c[1], "nullable": c[2]}
            for c in columns
        ]
        return json.dumps(result, indent=2)
    finally:
        conn.close()


@mcp.resource("schema://tables")
def get_schema() -> str:
    """Retorna el esquema completo de la base de datos."""
    return list_tables()


# Iniciar el servidor
if __name__ == "__main__":
    # mcp.run()
    mcp.run(transport="streamable-http")

# uv run mcp dev src/mcp/mcp-demo.py 
# cloudflared tunnel --url http://localhost:8000 
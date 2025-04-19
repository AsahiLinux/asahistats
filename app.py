#!/usr/bin/python3
import json

try:
    import psycopg
except ImportError:
    import psycopg2 as psycopg

g_conn = None

DBINFO = "dbname=asahistats user=asahistats"

def application(environ, start_response):
    global g_conn

    form = {}
    if environ['REQUEST_METHOD'] != "POST":
        start_response("400 Bad Request", [])
        yield b"Method not supported"
        return

    if g_conn is None:
        g_conn = psycopg.connect(DBINFO)
    
    try:
        cur = g_conn.cursor()
    except Exception:
        g_conn = psycopg.connect(DBINFO)
        cur = g_conn.cursor()

    try:
        content_length = int(environ['CONTENT_LENGTH'])
        if content_length > 131072:
            raise Exception("Too long")

        qs = environ["wsgi.input"].read(content_length)

        data = json.loads(qs)
        
        if "installer" not in data:
            raise Exception("Missing key")
        
        cur.execute("INSERT into stats (data) VALUES (%s);", (json.dumps(data),))
        g_conn.commit()
        cur.close()

        start_response("200 OK", [])
        yield b"Request OK"

    except Exception:
        start_response("400 Bad Request", [])
        yield b"Error processing request"
        raise

if __name__ == "__main__":
    from wsgiref.simple_server import make_server

    with make_server('', 8000, app) as httpd:
        print("Serving HTTP on port 8000...")

        httpd.serve_forever()

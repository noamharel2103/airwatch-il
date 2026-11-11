"""Local save server for Studio playtests (DataStores don't work in an unpublished place).
Run:  python tools/save_server.py      (listens on 127.0.0.1:34874)
Saves land in roblox-ai-tycoon/.saves/<key>.json
"""
import json, os, re
from http.server import BaseHTTPRequestHandler, HTTPServer

DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".saves")
os.makedirs(DIR, exist_ok=True)

def path_for(key):
    key = re.sub(r"[^A-Za-z0-9_\-]", "_", key)[:120]
    return os.path.join(DIR, key + ".json")

class H(BaseHTTPRequestHandler):
    def _send(self, code, body=b""):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        m = re.match(r"^/load/([^?]+)", self.path)
        if not m:
            return self._send(404)
        p = path_for(m.group(1))
        if not os.path.exists(p):
            return self._send(200, b"null")
        with open(p, "rb") as f:
            self._send(200, f.read())

    def do_POST(self):
        m = re.match(r"^/save/([^?]+)", self.path)
        if not m:
            return self._send(404)
        n = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(n)
        json.loads(body)  # validate
        with open(path_for(m.group(1)), "wb") as f:
            f.write(body)
        self._send(200, b'{"ok":true}')

    def do_DELETE(self):
        m = re.match(r"^/save/([^?]+)", self.path)
        if m and os.path.exists(path_for(m.group(1))):
            os.remove(path_for(m.group(1)))
        self._send(200, b'{"ok":true}')

    def log_message(self, *a):
        pass

if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 34874), H).serve_forever()

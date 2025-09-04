import http.server
import socketserver
import os
import subprocess
import secrets
import re
import html
import traceback
import json
import sys
from urllib.parse import parse_qs, urlparse

# --- Configuration ---
PORT = 8080  # Change this to your desired port
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_DIR = os.path.join(BASE_DIR, "config")
METADATA_DIR = os.path.join(BASE_DIR, "metadata")
CRED_DIR = os.path.join(BASE_DIR, "cred")
WG_CONF_SERVER = "/etc/wireguard/wg0.conf"
IP_FORMAT = "10.0.0.x" 
CLIENT_DNS = "1.1.1.1"

sessions = {}

class WireGuardWebUI(http.server.SimpleHTTPRequestHandler):

    def _send_headers(self, code=200, content_type="text/html", extra_headers=None):
        self.send_response(code)
        self.send_header("Content-type", content_type)
        if extra_headers:
            for key, value in extra_headers.items():
                self.send_header(key, value)
        self.end_headers()

    def _get_session_cookie(self):
        cookie_header = self.headers.get('Cookie')
        if cookie_header:
            cookies = dict(item.split("=") for item in cookie_header.split("; ") if "=" in item)
            return cookies.get('session_id')
        return None

    def _get_current_user(self):
        session_id = self._get_session_cookie()
        if session_id and session_id in sessions:
            return sessions[session_id]
        return None

    def _redirect(self, path):
        self._send_headers(302, extra_headers={"Location": path})

    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        query = parse_qs(parsed_path.query)

        if path == '/':
            self._redirect('/wgconf')
        elif path == '/wgconf':
            self.serve_wgconf_page()
        elif path == '/login':
            if self._get_current_user():
                return
            self.serve_login_page()
        elif path == '/logout':
            self.handle_logout()
        elif path == '/list':
            self.serve_list_page()
        elif path == '/admin':
            self.serve_admin_page()
        elif path == '/view_config':
            user = self._get_current_user()
            if not user:
                return
            self.handle_view_config(query)
        elif path.startswith('/download/'):
            user = self._get_current_user()
            if not user:
                return
            self.serve_config_download(path)
        else:
            self._send_headers(404)
            self.wfile.write(b"404 Not Found")

    def do_POST(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length).decode('utf-8')
        params = parse_qs(post_data)

        if path == '/login':
            self.handle_login(params)
        elif path == '/create_config':
            self.handle_create_config(params)
        elif path == '/admin/create_user':
            self.handle_create_user(params)
        elif path == '/admin/edit_user':
            self.handle_edit_user(params)
        elif path == '/admin/delete_user':
            self.handle_delete_user(params)
        elif path == '/delete_config':
            user = self._get_current_user()
            if not user:
                return
            self.handle_delete_config(params)
        else:
            self._send_headers(404)
            self.wfile.write(b"404 Not Found")

    # Additional methods for handling requests and responses would go here

if __name__ == "__main__":
    class ReusableTCPServer(socketserver.TCPServer):
        allow_reuse_address = True

    try:
        with ReusableTCPServer(("", PORT), WireGuardWebUI) as httpd:
            httpd.serve_forever()
    except OSError as e:
        print(f"[FATAL] Could not start server on port {PORT}. Error details: {e}", file=sys.stderr)
        sys.exit(1)
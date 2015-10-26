import os, sys, re, json, fnmatch
import logging
import flask
from flask import request, Response

CWD = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(CWD, 'static')
app = flask.Flask(__name__)
app.logger.addHandler(logging.StreamHandler(sys.stdout))

def request_ip():
    ip = request.remote_addr
    if request.headers.get("X-Forwarded-For"):
        ip = request.headers.get("X-Forwarded-For").split(',')[0].strip()
    return ip

def get_files_in(path, grab='*.*'):
    return [os.path.join(path, filename) for filename in fnmatch.filter(os.listdir(path), grab)]

def deis(data):
    c = {}
    if not data.strip():
        return c
    lines = data.strip().split("\n")
    ip = re.findall('inet ([.\d]+)', lines[0])[0]
    c.setdefault(ip, {})
    for row in lines[1:]:
        crow = row.split()
        name = crow[-1].split('_')[0]
        c[ip][name] = crow[0]
    return c

def list_containers():
    c = {}
    for f in get_files_in(STATIC_DIR):
        c.update(deis(open(f).read()))
    return c

@app.route('/a/<name>')
def app_shorthand(name):
    cmd = "-A -t -p {port} {user}@{ip} {token}"
    for ip, apps in list_containers().iteritems():
        match = apps.get(name, None)
        if match:
            cmd = cmd.format(ip=ip,
                    token=match,
                    user=os.getenv('APP_USER', 'dca'),
                    port=os.getenv('APP_PORT', 222),)
            break
    return Response(cmd)

@app.route('/')
def index():
    c = list_containers()
    return Response(json.dumps(c), content_type="application/json")

@app.route('/clear', methods=["POST"])
def clear():
    for f in get_files_in(STATIC_DIR):
        os.remove(f)

@app.route('/incoming', methods=["POST"])
def incoming():
    """ Each Deis host sends information """
    data = request.data
    with open(os.path.join(STATIC_DIR, request_ip()), 'w+') as f:
        f.write(data)
    return Response('OK')

if __name__ == '__main__':
    app.run(host=os.getenv('APP_HOST', '0.0.0.0'),
            port=os.getenv('APP_PORT', 8000),
            debug=bool(os.getenv('APP_DEBUG', False)),
            )

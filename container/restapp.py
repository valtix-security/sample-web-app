import os
import json
import argparse
from flask import Flask, request

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST', 'PUT', 'DELETE'])
@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def index(path=""):
    hdrs = dict(request.headers)
    hdrs['Method'] = request.method
    hdrs['Client'] = request.remote_addr
    return json.dumps(hdrs, indent=4, sort_keys=True) + "\n"
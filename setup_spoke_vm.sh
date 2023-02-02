apt update
apt install -y nginx ssl-cert python3-flask gunicorn

echo "Create nginx default site"
cat <<EOF > /etc/nginx/sites-enabled/default
server {
    listen 80 default_server;
    listen 443 ssl default_server;
    include snippets/snakeoil.conf;

    root /var/www/html;

    server_name _;

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        proxy_ssl_server_name on;
        proxy_ssl_name \$host;
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header sni $ssl_server_name;
        proxy_set_header x-forwarded-for \$proxy_add_x_forwarded_for;
        #try_files \$uri \$uri/ =404;
    }
}
EOF

echo "Create /svc and the restapp.py"
mkdir /svc
cat <<EOF > /svc/restapp.py
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
EOF

num_workers=$(cat /proc/cpuinfo | grep processor | wc -l)

echo "Create restapp systemd service"
cat <<EOF > /etc/systemd/system/restapp.service
[Unit]
Description=Run restapp that returns back all the headers
After=network.target

[Service]
User=ubuntu
Group=ubuntu
ExecStart=/usr/bin/gunicorn --chdir /svc -w $num_workers restapp:app

[Install]
WantedBy=multi-user.target
EOF

echo "Restart services"
systemctl daemon-reload
systemctl restart nginx
systemctl start restapp

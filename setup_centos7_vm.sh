setenforce 0
yum install -y epel-release
yum install -y nginx python3 python36-flask python36-gunicorn

FQDN=app1.myorg.com

openssl genrsa -out myca.key 2048
# password protect key: openssl genrsa -out myca.key -des3 2048
openssl req -x509 -new -key myca.key -sha384 -days 1825 -out myca.crt \
  -subj "/C=US/ST=CA/L=Santa Clara/O=MyOrg/OU=SecurityOU/CN=rootca.myorg.com/emailAddress=rootca@myorg.com"

openssl genrsa -out app1.key 2048
openssl req -new -key app1.key -out app1.csr \
  -subj "/C=US/ST=CA/L=Santa Clara/O=MyOrg/OU=AppOU/CN=app1.myorg.com/emailAddress=app1@myorg.com"
openssl x509 -req -in app1.csr -CA myca.crt -CAkey myca.key -out app1.crt -sha384 \
  -days 365 -CAcreateserial -extensions SAN \
  -extfile <(printf "[SAN]\nbasicConstraints=CA:false\nsubjectAltName=DNS:$FQDN")

mkdir /etc/pki/nginx
mkdir /etc/pki/nginx/private
mv app1.crt /etc/pki/nginx/
mv app1.key /etc/pki/nginx/private/

cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen 80 default_server;
    listen 443 ssl default_server;
    ssl_certificate "/etc/pki/nginx/app1.crt";
    ssl_certificate_key "/etc/pki/nginx/private/app1.key";

    root /var/www/html;

    server_name _;

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        proxy_ssl_server_name on;
        proxy_ssl_name \$host;
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header sni \$ssl_server_name;
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
User=centos
Group=centos
ExecStart=/bin/gunicorn-3 --chdir /svc -w $num_workers restapp:app

[Install]
WantedBy=multi-user.target
EOF

echo "Restart services"
systemctl daemon-reload
systemctl restart nginx
systemctl start restapp

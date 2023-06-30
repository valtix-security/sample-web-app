systemctl stop nginx
cd /svc
CERT=/etc/ssl/certs/ssl-cert-snakeoil.pem
KEY=/etc/ssl/private/ssl-cert-snakeoil.key
gunicorn --certfile $CERT --keyfile $KEY -w 5 restapp:app --bind 0.0.0.0:443 --access-logfile /dev/stdout -t 0 -d

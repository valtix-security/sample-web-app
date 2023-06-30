# To run the app using gunicorn directly without going through nginx, to simulate longer time outs etc
systemctl stop nginx
systemctl stop restapp
cd /svc
CERT=/etc/ssl/certs/ssl-cert-snakeoil.pem
KEY=/etc/ssl/private/ssl-cert-snakeoil.key
gunicorn --certfile $CERT --keyfile $KEY -w 5 restapp:app --bind 0.0.0.0:443 --access-logfile /dev/stdout -t 0 -D

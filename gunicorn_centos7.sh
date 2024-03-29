# To run the app using gunicorn directly without going through nginx, to simulate longer time outs etc
systemctl stop nginx
systemctl stop restapp
cd /svc
CERT=/etc/pki/nginx/app1.crt
KEY=/etc/pki/nginx/private/app1.key
gunicorn-3 --certfile $CERT --keyfile $KEY -w 5 restapp:app --bind 0.0.0.0:443 --access-logfile /dev/stdout -t 0 -D

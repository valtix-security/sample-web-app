FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y nginx ssl-cert python3-flask gunicorn supervisor && \
    mkdir /svc
COPY restapp.py /svc
COPY supervisord.conf /svc
COPY nginx-default.conf /etc/nginx/sites-enabled/default
WORKDIR /svc
CMD ["/usr/bin/supervisord", "-c", "supervisord.conf"]

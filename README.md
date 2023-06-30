A sample web application to run on a VM
* Install nginx, python flask and other support applications to run flask apps
* Install ssl-certificates (sample ones but good for testing)
* Run nginx on port 80 and port 443
* Run flask app on localhost:8000
* Setup proxy on nginx to go to flask app
* Flask app just returns all the headers back as the response
* Flask app supports GET PUT POST and DELETE on all the paths
* Create a system service to run this app

# Run the script as root user on ubuntu host
```
bash setup_ubuntu_vm.sh
curl localhost
curl -k https://localhost
```

# To run flask app as root user without going through nginx proxy
```
bash gunicorn_ubuntu.sh
```

# Run the script as root user on centos 7 host
```
sudo bash setup_centos7_vm.sh
curl localhost
curl -k https://localhost
```

# To run flask app as root user without going through nginx proxy
```
bash gunicorn_centos7.sh
```

# To run flask app via nginx
```
ps -ef | grep gunicorn
kill the parent gunicorn process
systemctl start nginx
systemctl start restapp
```


# Running in a container
```
cd container
docker build -t app .
docker run -d --rm -p 8000:80 -p 8443:443 app
```

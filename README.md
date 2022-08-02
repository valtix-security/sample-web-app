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
bash setup_spoke_vm.sh
```

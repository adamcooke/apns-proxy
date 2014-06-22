# APNS Proxy

This is a Rails application which orchestrates the sending of push notifications
from applications to the Apple Push Notification Service (APNS). Rather than 
individual applications talking to APNS directly, they send an HTTP request to
this service which maintains a connection to the APNS service and delivers
the notification down this persistent connection.

* Manage multiple applications
* Handle multiple environments per application - different APNS certificates
  for your Beta, Release and Debug builds if needed.
* Keep track of the notifications sent.
* Monitors for device unsubscriptions and alerts the sending application next
  time it tries to send a message.

## Installation

To install this service, just follow these instructions. Before you run these
be sure to set up a backend database. At present only MySQL has been tested.

```
git clone git://github.com/adamcooke/apns-proxy.git
cd apns-proxy
bundle install --without development
# Open config/database.yml and add appropriate DB connection details
rake db:schema:load
rake apns_proxy:setup
```

Once this is setup, you can then run the tasks outlined in the next section.
The default username is **admin** and the default password is **password**.

## Server Tasks

* **Web Server** - you should run the web server to provide an admin interface
  as well as the HTTP API service used for sending notifications. This runs
  continuously.
  
  ```
  rails server
  ```
  
* **Worker** - the worker is responsible for sending notifications from the 
  local system to the APNS backend. This runs continuously.
  
  ```
  rake apns_proxy:worker
  ```

* **Unsubscriber** - this runs on a daily basis and gets a list of device 
  which APNS has detected as no longer having the application installed. This
  information is then used to mark a device as unsubscribed.
  
  ```
  rake apns_proxy:unsubscribe
  ```

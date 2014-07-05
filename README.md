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

## API Methods

This section outlines the HTTP API methods which are available to you and are
used for sending notifications and registering devices.

This is an HTTP JSON API and parameters should be sent as JSON in the body of
the HTTP request. It is recommended that you use the POST HTTP verb for all
requests. Any parameters shown below which include periods represent a hash
which should be passed.

### Sending Notifications

In order to send a notification, you will need an `auth_key` and a device
identifier.

```
POST /api/notify
```

* `auth_key` - your auth key (string, required)
* `device` - the device identifier (string, required)
* `notification.alert.body` - the text body for your notification (string)
* `notification.alert.action_loc_key` - localization key for your action button (string)
* `notification.alert.loc_key` - localization key for your alert message (string)
* `notification.alert.log_args` - arguments for your localization (array of strings)
* `notification.alert.launch_image` - the launch image to display (string)
* `notification.sound` - the name of a sound file to play (string)
* `notification.badge` - the badge to display on the app (integer)
* `notification.content_available` - whether content is available or not (boolean)
* `notification.custom_data` - custom data to return to the API (hash)

**NOTE:** APNS allows a maximum of 256 bytes to be sent to them so you should
ensure that your notification is smaller than this. There is a some overhead.
If your notification is too big, the interface will provide you with a `2000`
error code.

When you submit this, you will receive either a `201 Created` status which
means that your notification was added and delivery will be attempted. If there
is an error, you'll receive a `422 Unprocessable Entity` status and the response
body will contain an array of `errors`. 

The most significant thing to look out for is information that a device you
are sending notifications for has been unsubscribed. Such an issue will look 
this like in the response body:

```javascript
{
  "errors": {
    "device": [ "unsubscribed" ]
  }
}
```

### Registering devices

It is strongly recommended to let the proxy service know whenever a new device
is registered with your application. This allows us to help manage the
unsubscriptions for your application and ensure that certificates aren't
blocked by Apple.

```
POST /api/register
```

* `auth_key` - your auth key (string, required)
* `device` - the device identifier (string, required)
* `label` - a label to identified this device in the admin UI (string)

You will always receive a `200 OK` from this message with a response body 
similar to that shown below:

```javascript
{
  "device": 1,
  "status": "ok"
}
```

## Licence

This software is licenced under the MIT-LICENSE.


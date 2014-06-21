# Pat

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

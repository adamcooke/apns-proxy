Thread.abort_on_exception = true
$stdout.sync = true
$stderr.sync = true

module ApnsProxy
  class Worker

    def initialize
    end

    def run
      trap("SIGINT") { puts "Exiting..." ; Process.exit(0) }
      trap("SIGTERM") { puts "Exiting..." ; Process.exit(0) }
      puts "Started APNS Proxy worker"

      connections = {}
      channel = ApnsProxy::RabbitMq.create_channel
      channel.prefetch(1)
      queue = channel.queue("apnsproxy-notifications", :durable => true, :arguments => {'x-message-ttl' => 120000})
      queue.subscribe do |delivery_info, properties, body|
        begin
          payload = JSON.parse(body)
          puts payload.inspect

          if connections[payload['environment_id']]
            connection = connections[payload['environment_id']]
            puts "Using cached connection for #{payload['environment_id']}"
          else
            environment = Environment.find(payload['environment_id'])
            connection = connections[payload['environment_id']] = environment.create_apnotic_connection
            connection.on(:error) do |e|
              # If an error occurs on our HTTP socket, we'll print the details, delete this
              # connection from the pool.
              puts "Error on HTTP socket: #{e.class} (#{e.message})"
              puts e.backtrace
              connections.delete_if { |k,v| v == connection }
            end
            puts "Created connection for #{payload['environment_id']}"
          end

          if notification = Notification.find_by_id(payload['id'])
            response = connection.push(notification.apnotic_notification)
            if response.status == '200'
              notification.mark_as_pushed!
              puts "[N#{notification.id}] Sent successfully"
            else
              if response.status == '410' || (response.status == '400' && response.body['reason'] == 'BadDeviceToken')
                notification.device.unsubscribe!
              end
              notification.status_code = response.status
              notification.status_reason = response.body['reason']
              notification.save!
              puts "[N#{notification.id}] Failed to send notification (#{response.status}: #{response.body['reason']})"
            end
          end

          @should_retry = false
        rescue => e
          puts "Error while sending notification: #{e.class} (#{e.message})"
          puts e.backtrace
          connections.delete(payload['environment_id'])
          @should_retry = !@should_retry
          if @should_retry
            puts "Retrying once..."
            retry
          end
        end
      end

      loop { sleep 10 }
    end

  end
end

module ApnsProxy
  class Worker

    def initialize
    end

    def run
      $running_job = false
      Signal.trap("INT")  { $exit = true }
      Signal.trap("TERM") { $exit = true }

      channel = ApnsProxy::RabbitMq.create_channel
      channel.prefetch(1)
      queue = channel.queue("apnsproxy-notifications", :durable => true, :arguments => {'x-message-ttl' => 120000})
      puts "Started APNS Proxy worker"
      queue.subscribe(:manual_ack => true) do |delivery_info, properties, body|
        begin
          $running_job = true
          payload = JSON.parse(body)
          if notification = Notification.find_by_id(payload['id'])
            with_connection(notification.auth_key.environment) do |connection|
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
          else
            puts "No notification found with id #{payload['id']}"
          end
        rescue => e
          puts "Error: #{e.class.name}: #{e.message}"
          puts e.backtrace
        ensure
          channel.ack(delivery_info.delivery_tag)
          $running_job = false
          if $exit
            puts "Exiting because a job has ended."
            exit 0
          end
        end
      end

      puts "Waiting for jobs..."

      exit_checks = 0
      loop do
        if $exit && $running_job == false
          puts "Exiting immediately because no job running"
          exit 0
        elsif $exit
          if exit_checks >= 60
            puts "Job did not finish in a timely manner. Exiting"
            exit 0
          end
          if exit_checks == 0
            puts "Exit requested but job is running. Waiting for job to finish."
          end
          sleep 60
          exit_checks += 1
        else
          sleep 1
        end
      end
    end

    private

    def connection_pool
      @connection_pool ||= {}
    end

    def with_connection(environment, retried = false, &block)
      connection = connection_pool[environment] || create_connection(environment)
      begin
        block.call(connection)
        return true
      rescue => e
        puts "Error: #{e.class.name}: #{e.message}"
        puts e.backtrace
        # All errors experienced will result in the connection being dropped,
        # a new connection created and retried
        connection.close rescue nil
        connection_pool.delete(environment)
        if retried
          puts "Already retried. Won't try again."
          return false
        else
          with_connection(environment, true, &block)
        end
      end
    end

    def create_connection(environment)
      cert = StringIO.new(environment.certificate)
      if environment.development?
        Apnotic::Connection.development(:cert_path => cert)
      else
        Apnotic::Connection.new(:cert_path => cert)
      end
    end

  end
end

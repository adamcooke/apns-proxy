module ApnsProxy
  class Worker

    def initialize
    end

    def run
      trap("SIGINT") { puts "Exiting..." ; Process.exit(0) }
      trap("SIGTERM") { puts "Exiting..." ; Process.exit(0) }
      puts "Started APNS Proxy worker"
      loop do
        start_environment_threads
        sleep 5
      end
    end

    private

    def threads
      @threads ||= {}
    end

    def start_environment_threads
      acceptable_environments = []
      Environment.all.each do |environment|
        acceptable_environments << environment.id
        if threads[environment.id].nil? || !threads[environment.id].alive?
          puts "Starting thread for environment #{environment.id}"
          threads[environment.id] = start_environment_thread(environment)
        end
      end

      threads.each do |id, thread|
        if thread.alive? && !acceptable_environments.include?(id)
          puts "Killing thread for environment #{id}"
          thread.kill
        end
      end

      threads.delete_if { |_,t| !t.alive? }
    end

    def start_environment_thread(environment)
      Thread.new do |thread|
        dispatch(environment)
      end
    end

    def dispatch(environment)
      channel = ApnsProxy::RabbitMq.create_channel
      channel.prefetch(1)
      queue = channel.queue("apnsproxy-notifications-#{environment.id}", :durable => true, :arguments => {'x-message-ttl' => 120000})
      puts "Connected to queue for #{environment.id}"
      connection = nil
      queue.subscribe do |delivery_info, properties, body|
        begin
          while connection.nil?
            connection = environment.create_apnotic_connection
            connection.instance_variable_get("@client").on(:error) do |e|
              puts "Got exception: #{e.class} #{e.message}"
              puts "Resetting connection..."
              connection.close rescue nil
              connection = nil
            end
          end
          payload = JSON.parse(body)
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
        rescue => e
          puts "Error while sending notification: #{e.class} (#{e.message})"
          puts e.backtrace
          connection.close rescue nil
        end
      end
      loop { sleep 10 }
    rescue => e
      puts "Error in loop: #{e.class} (#{e.message}"
      puts e.backtrace
    ensure
      queue.unsubscribe rescue nil
      channel.stop rescue nil
      connection.close rescue nil
    end

  end
end

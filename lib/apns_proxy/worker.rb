module ApnsProxy
  class Worker
    
    def self.run
      
      Signal.trap("INT")  { @stop = true }
      Signal.trap("TERM")  { @stop = true }
      
      puts "Started APNS Proxy worker..."
      
      #
      # Stores global connection objects which will be used throughout the.
      #
      connections = {}
      
      loop do

        #
        # Used for storing any errors which are sent from Apple.
        #
        error = nil
        
        #
        # Used for storing the connections which we will see during this notification
        # loop.
        #
        connections_in_loop = []
        
        #
        # Get all notifications which need pushin to the Apple service and loop
        # through them all.
        #
        Notification.requires_pushing.unlocked.each do |notification|
          
          #
          # Get a lock?
          #
          if Notification.where(:id => notification.id, :locked => false).update_all({:locked => true}) != 1
            puts "[N#{notification.id.to_s.rjust(7, '0')}] Couldn't get lock on notification"
            next
          end
          
          # 
          # Check that we should still send this notification
          #
          if notification.created_at < 5.minutes.ago
            puts "[N#{notification.id.to_s.rjust(7, '0')}] Expiring notification"
            notification.mark_as_failed!(2000)
            next
          end
          
          #
          # Get a connection
          #
          connection = connections[notification.auth_key.environment.id]
          if connection.nil?
            connection = connections[notification.auth_key.environment.id] = notification.auth_key.environment.create_connection
          end
                    
          #
          # Open the connection if it isn't open
          #
          begin
            unless connection.open?
              puts "Opening connection for #{notification.id}"
              connection.open
            end
          rescue OpenSSL::PKey::RSAError
            puts "----> Invalid certificate/key has been provided for the environment".red
            connections[notification.auth_key.environment.id] = nil
            notification.mark_as_failed!(3000)
            next
          end
          
          #
          # Add this to the connections we just looked at
          #
          connections_in_loop << connection 
          
          #
          # Generate a houston notification
          #
          houston_notification = notification.to_houston_notification
          
          #
          # Check the notification is valid
          #
          unless notification.valid?
            puts "[N#{notification.id.to_s.rjust(7, '0')}] Could not be sent as it was not valid.".yellow
            notification.mark_as_failed!(1000)
            next
          end
          
          begin
            
            puts "[N#{notification.id.to_s.rjust(7, '0')}] Sending using connection #{notification.auth_key.environment.id} (#{notification.auth_key.environment.name} for #{notification.auth_key.environment.application.name})".green
            
            # 
            # Write this message to the service
            #
            connection.write(houston_notification.message)
            
            #
            # After sending a notification wait a little bit to give Apple a chance
            # to reply about our latest notification before proceding to the 
            # next in the queue.
            #
            sleep 0.5

            #
            # Check for any errors on the socket and break out of the current loop
            # so the error can be addressed before processing any other notifications.
            #
            ssl = connection.ssl
            read_socket, write_socket = IO.select([ssl], [ssl], [ssl], nil)
            if (read_socket && read_socket[0])
              error = connection.read(6)
              connection.close
              break
            end
            
            #
            # Mark the latst notification as sent as we don't have any reason at
            # the moment to think otherwise.
            #
            notification.mark_as_pushed!

          rescue Errno::EPIPE => e
            #
            # Pipes are closed when the connection hsa been closed by Apple but
            # we haven't read the error. This shouldn't happen very often but catching
            # it will avoid needing to restart all connections when one is closed.
            #
            puts "Pipe was closed. Marking connection as closed.".red
            connection.close
          end
          
        end
        
        #
        # Check for errors on any of the connections which were used in the latest
        # notification loop. In a low volume environment this will probably only ever
        # be a single connection. In most cases, this will never be used as the 
        # error will be detected above but if Apple don't reply in a timely manner
        # it's possible errors will be loitering on the socket and need to be seen.
        #
        connections_in_loop.each do |connection|
          if connection.open?
            read_socket, write_socket = IO.select([connection.ssl], [connection.ssl], [connection.ssl], nil)
            if (read_socket && read_socket[0])
              error = connection.read(6)
              connection.close
            end
          end
        end
        
        #
        # If there were any errors, handle it.
        #
        if error
          command, status, index = error.unpack("ccN")
          if failed_notification = Notification.find_by_id(index)
            unless status == 10
              #
              # Unless the status is 10 (Shutdown) mark this notification as failed.
              # In a status 10 situation, the passed notification is the last successful
              # notification therefore we don't need to do anything other than resend future
              # notifications.
              #
              puts "[N#{failed_notification.id.to_s.rjust(7, '0')}] Marking notification as failed (command: #{command} status: #{status})".yellow
              failed_notification.mark_as_failed!(status)
            end
            
            #
            # Get all notifications since the failed notification and mark them as re-sendable and try again.
            # It's likely we sent them to the socket after this failed notification and they were ignored. 
            # This only sends notifications which use the same auth key as the failed notification to avoid
            # resending notifications for other connections which may be OK.
            #
            Notification.where("auth_key_id = ? AND id > ?", failed_notification.auth_key_id, index).each do |repushable_notification|
              puts "[N#{repushable_notification.id.to_s.rjust(7, '0')}] Marking as repushable"
            end
          end
          error = nil
        end
        
        #
        # If we should stop, let's just stop the loop
        #
        if @stop
          puts "Stopping worker..."
          break
        end
        
        #
        # Sleep for one second before looking for new notifications to be sent.
        #
        sleep 1
      end
      
    rescue => e
      #
      # An exception occurred. This is often not a good thing and shouldn't happen.
      # We'll reset everything and start again and hope things have gone away in
      # 30 seconds.
      #
      # Apple won't like repeated connections to their service so we'll only do 
      # this for a maximum of 5 times then we'll die as something is up.
      #
      puts "An error occurred: #{e.exception.class} (#{e.message})".red
      puts e.backtrace
      @retries ||= 1
      if @retries >= 5
        puts "---> Re-raising the error after #{@retries} retries. Sorry - don't blame me.".red
        raise
      else
        puts "---> Closing all conncetions".red
        connections.each { |_,c| c.close }
        connections = {}
        puts "---> Waiting 30 seconds before retrying the worker loop from scratch".red
        sleep 30
        @retries  += 1
        retry        
      end
    ensure
      #
      # Always close all connections when this script stops
      #
      connections.each do |environment_id, connection|
        puts "Closing connection for #{environment_id}"
        connection.close 
      end
    end
    
  end
end
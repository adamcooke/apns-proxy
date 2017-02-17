module ApnsProxy
  module RabbitMq
    def self.create_connection
      conn = Bunny.new(
        :host => ENV["RMQ_HOST"] || 'localhost',
        :port => ENV["RMQ_PORT"] || 5672,
        :username => ENV["RMQ_USERNAME"] || 'guest',
        :password => ENV["RMQ_PASSWORD"] || 'guest',
        :vhost => ENV['RMQ_VHOST'] || "/"
      )
      conn.start
      conn
    end

    def self.create_channel
      conn = self.create_connection
      conn.create_channel
    end

    def self.channel
      @channel ||= begin
        @queues = {}
        create_channel
      end
    end

    def self.queue(name)
      @queues ||= {}
      @queues[name] ||= channel.queue(name, :durable => true, :arguments => {'x-message-ttl' => 120000})
    end

    def self.with_queue(name, retried = false, &block)
      begin
        block.call(queue(name))
      rescue Bunny::Exception => e
        if retried
          raise
        else
          @channel = nil
          with_queue(name, true, &block)
        end
      end
    end
  end
end

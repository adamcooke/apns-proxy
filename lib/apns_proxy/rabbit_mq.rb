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

    def self.queue
      @channel ||= begin
        channel = self.create_channel
        channel.queue("apnsproxy-notifications", :durable => true, :arguments => {'x-message-ttl' => 120000})
      end
    end
  end
end

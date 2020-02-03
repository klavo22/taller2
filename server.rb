require "socket"
require "byebug"

require_relative "lib/lru_cache"
require_relative "lib/logger"
require_relative "lib/connection"

class Server

  def initialize(port)
    @server = TCPServer.new port
  end

  def start
    cache = LRUCache.new
    port = @server.local_address.ip_port
    puts "Memcached server is started at port #{port}"

    loop do
      Thread.start(@server.accept) do |client|  
        puts "\nClient connected...\n\n"
        Connection.new(cache, client).perform
      end
    end
  end

end

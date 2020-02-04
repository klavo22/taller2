require_relative "../commands/storage"
require_relative "../commands/retrieval"
require_relative "request_parser"
require_relative "request_processor"

class Connection
  
  attr_accessor :client

  def initialize(cache, client)
    @cache  = cache
    @client = client
  end
  
  def perform
    
    while client
      input = client.gets
      
      redo unless !input.nil? 

      Logger.info(input)

      input = input.split

      command_class = input.first.start_with?("get") ? Commands::Retrieval : Commands::Storage 

      request = command_class.new(client, input).create_request

      redo unless !request.nil?

      request = RequestParser.parse(request)

      result = RequestProcessor.send(request[:command], request)

      client.puts result unless request[:no_reply]
      
    end
  end
end
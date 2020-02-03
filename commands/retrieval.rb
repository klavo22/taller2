require_relative "base"

module Commands
  class Retrieval < Base
    def create_request
      
      command = @options.first
      
      keys = []

      @options[1..-1].each do |key|
        keys << key
      end

      return client_puts "ERROR" if error?

      request = {command: command, keys: keys}
    end

    private 

    def error?
      !Commands::RETRIEVAL.include?(@options.first) || @options[1].empty?
    end

  end
end
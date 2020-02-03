require_relative "base"
require_relative "storage/validator"

module Commands
  class Storage < Base
    def create_request

      command = @options[0]
      options = prettify_options
      
      return client_puts("ERROR") if Validator.error?(options)
      return client_puts("CLIENT_ERROR bad command line format") if Validator.client_error?(options)

      value = client_gets
      
      Logger.info(value, add: true)

      return client_puts("CLIENT_ERROR bad data chunk") if Validator.invalid_bytes?(options[:bytes], value)

      options[:value] = value

      return options
    end

    private

    def prettify_options
      {   
        command:   @options[0],
        key:       @options[1],
        flags:     @options[2],
        exptime:   @options[3],
        bytes:     @options[4],
        cas_token: @options[0] == "cas" ? @options[5] : nil,
        no_reply:  no_reply?
      }
    end

    def no_reply?
      return true if @options[0] == "cas" && @options[6] == "noreply"
      return true if @options[0] != "cas" && @options[5] == "noreply"
      false
    end
  end
end
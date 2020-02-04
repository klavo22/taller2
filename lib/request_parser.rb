require_relative 'element'

module RequestParser
  module_function

  def parse(request)

    if Commands::STORAGE.include?(request[:command])
      element = Element.new(
        request[:value],
        request[:flags].to_i,
        request[:exptime].to_i != 0 ? Time.now + request[:exptime].to_i : request[:exptime].to_i
      )
      cas_token = request[:command] == "cas" ? request[:cas_token].to_i : nil 
      return {command: request[:command], key: request[:key], element: element, cas_token: cas_token, no_reply: request[:no_reply]}
    elsif Commands::RETRIEVAL.include?(request[:command]) 
      return request
    end
  end
end
module RequestParser
  module_function

  def parse(request)

    if Commands::STORAGE.include?(request[:command])
      request[:flags]      = request[:falgs].to_i
      request[:exptime]    = request[:exptime].to_i > 0 ? Time.now + request[:exptime].to_i : request[:exptime].to_i
      request[:bytes]      = request[:bytes].to_i
      request[:cas_token]  = request[:command] == "cas" ? request[:cas_token].to_i : nil 
      return request 
    elsif Commands::RETRIEVAL.include?(request[:command]) 
      return request
    end
  end
end
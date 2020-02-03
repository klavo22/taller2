module Logger
  def self.info(msg, add: false) 
    puts msg
    puts "-" * 20 if add
  end
end

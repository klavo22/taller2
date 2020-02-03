module Validator

  extend self

  MAX_32_BIT_UNSIGNED = 4294967295
  MAX_64_BIT_UNSIGNED = 18446744073709551615

  def error?(options)
    !Commands::STORAGE.include?(options[:command]) || params_are_blank?(options)
  end

  def client_error?(options)
    return true unless !values_are_not_int?(options)
    return true unless !invalid_flags?(options[:flags]) 
    return true unless !( cas?(options[:command]) && invalid_token?(options[:cas_token]) )
    false
  end

  def invalid_bytes?(bytes, value)
    value.size != bytes.to_i
  end

  private

  def params_are_blank?(options)
    keys = [:key, :flags, :exptime, :bytes]
    keys.push(:cas_token) if cas?(options[:command])

    keys.any? do |key|
      options[key].nil? || options[key].empty?
    end
  end

  def values_are_not_int?(options)
    return true unless is_int?(options[:flags])
    return true unless is_int?(options[:exptime], allow_negative: true)
    return true unless is_int?(options[:bytes])
    return false
  end

  def is_int?(value, allow_negative: false)
    if !allow_negative
      return !value.match(/^\d+$/).nil?
    else
      return !value.match(/^(-?)\d+$/).nil?
    end
  end

  def invalid_flags?(flags)
    flags.to_i > MAX_32_BIT_UNSIGNED
  end

  def invalid_token?(token)
    token.to_i > MAX_64_BIT_UNSIGNED || !is_int?(token)
  end

  def cas?(command)
    command == "cas"
  end
end

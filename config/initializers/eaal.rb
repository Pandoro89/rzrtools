EAAL.cache = EAAL::Cache::FileCache.new(File.join(Rails.root,"tmp","eaal"))

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
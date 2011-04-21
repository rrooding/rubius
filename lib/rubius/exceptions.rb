module Rubius
  class Error < RuntimeError; end
  class InvalidDictionaryError < Error; end
  class MissingConfiguration < Error; end
  class MissingEnvironmentConfiguration < Error; end
end

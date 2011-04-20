require 'rubygems'
require 'bundler'
require 'simplecov'
SimpleCov.start
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubius'

class Test::Unit::TestCase
end

RADIUS_DICTIONARY = [
  "# -*- text -*-",
  "#",
  "#	Attributes and values defined in RFC 2865.",
  "ATTRIBUTE	User-Name				1	string",
  "ATTRIBUTE	User-Password				2	string encrypt=1",
  "ATTRIBUTE	Service-Type				6	integer",
  "",
  "# Values",
  "VALUE	Service-Type			Login-User		1",
  "VALUE	Service-Type			Framed-User		2",
  "VALUE	Service-Type			Callback-Login-User	3",
  "",
  "# -*- text -*-",
  "#",
  "# dictionary.cisco",
  "VENDOR		Cisco				9",
  "",
  "BEGIN-VENDOR	Cisco",
  "",
  "ATTRIBUTE	Cisco-AVPair				1	string",
  "ATTRIBUTE	Cisco-NAS-Port				2	string",
  "ATTRIBUTE	Cisco-Disconnect-Cause			195	integer",
  "",
  "VALUE	Cisco-Disconnect-Cause		Unknown			2",
  "VALUE	Cisco-Disconnect-Cause		CLID-Authentication-Failure 4",
  "#",
  "",
  "VENDOR		Juniper				2636",
  "",
  "BEGIN-VENDOR	Juniper",
  "",
  "ATTRIBUTE	Juniper-Local-User-Name			1	string"
]

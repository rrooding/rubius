module Rubius
  require 'singleton'
  require 'socket'
  require 'yaml'
  
  class Authenticator
    include Singleton
    
    def initialize
      @dictionary = Rubius::Dictionary.new
      @packet = nil
      @secret = nil
      
      @host = nil
      @port ||= Socket.getservbyname("radius", "udp")
      @port ||= 1812
      
      @timeout = 10
      
      @sock = nil
      
      @identifier = Process.pid & 0xff
    end
    
    def init_from_config(config_file, env=nil)
      if env.nil?
        env = defined?(::Rails) ? ::Rails.env : 'development'
      end
      
      config = YAML.load_file(config_file)
      raise Rubius::MissingEnvironmentConfiguration unless config.has_key?(env)
      
      @host = config[env]["host"]
      @port = config[env]["port"] if config[env]["port"]
      @secret = config[env]["secret"]
      
      if config[env]["dictionary"]
        dict = File.join(File.dirname(config_file), config[env]["dictionary"])
        @dictionary.load(dict) if File.exists?(dict)
      end
      
      @nas_ip = config[env]["nas_ip"] if config[env]["nas_ip"]
      @nas_ip ||= UDPSocket.open {|s| s.connect(@host, 1); s.addr.last }
      
      setup_connection
    rescue Errno::ENOENT
      raise Rubius::MissingConfiguration
    end
    
    def authenticate(username, password)
      init_packet
      
      @packet.code = Rubius::Packet::ACCESS_REQUEST
      @packet.secret = @secret
      rand_authenticator
      
      @packet.set_attribute('User-Name', username)
      @packet.set_attribute('NAS-IP-Address', @nas_ip)
      @packet.set_password(password)
      
      send_packet
      recv_packet
      
      return(@packet.code == Rubius::Packet::ACCESS_ACCEPT)
    end
    
    def self.authenticate(username, password)
      Rubius::Authenticator.instance.authenticate(username, password)
    end
    
    private
    def init_packet
      increment_identifier!
      @packet = Rubius::Packet.new(@dictionary)
      @packet.identifier = @identifier
    end
    
    def increment_identifier!
      @identifier = (@identifier + 1) & 0xff
    end
    
    def setup_connection
      @sock = UDPSocket.open
      @sock.connect(@host, @port)
    end
    
    def rand_authenticator
      if (File.exists?("/dev/urandom"))
        File.open("/dev/urandom") { |rand| @packet.authenticator = rand.read(16) }
      else
        @packet.authenticator = [rand(65536), rand(65536), rand(65536), rand(65536), rand(65536), rand(65536), rand(65536), rand(65536)].pack("n8")
      end
      @packet.authenticator
    end
    
    def send_packet
      data = @packet.pack
      increment_identifier!
      @sock.send(data, 0)
    end
    
    def recv_packet
      if select([@sock], nil, nil, @timeout) == nil
        raise "Timed out waiting for response packet from server"
      end
      data = @sock.recvfrom(65536)
      @packet.unpack(data[0])
      @identifier = @packet.identifier
      return @packet
    end
  end
end

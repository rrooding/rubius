module Rubius
  require 'ipaddr'
  require 'digest/md5'
  
  class Packet
    PACK_HEADER = 'CCna16a*'
    HEADER_LENGTH = 1 + 1 + 2 + 16
    VSA_TYPE = 26
      ACCESS_REQUEST = 'Access-Request'
      ACCESS_ACCEPT = 'Access-Accept'
      ACCESS_REJECT = 'Access-Reject'
      ACCOUNTING_REQUEST = 'Accounting-Request'
      ACCOUNTING_RESPONSE = 'Accounting-Response'
      ACCESS_CHALLENGE = 'Access-Challenge'
      STATUS_SERVER = 'Status-Server'
      STATUS_CLIENT = 'Status-Client'
    RESPONSES = {   1 => ACCESS_REQUEST,
                    2 => ACCESS_ACCEPT,
                    3 => ACCESS_REJECT,
                    4 => ACCOUNTING_REQUEST,
                    5 => ACCOUNTING_RESPONSE,
                    11 => ACCESS_CHALLENGE,
                    12 => STATUS_SERVER,
                    13 => STATUS_CLIENT}
                    
    attr_accessor :identifier
    attr_accessor :secret
    attr_accessor :code
    attr_accessor :authenticator
    
    def initialize(dictionary)
      @dictionary = dictionary
      @attributes = Hash.new
      @secret = nil
    end
    
    def unpack_attribute(data, type)
      val = case type 
      when 'string'
        data
      when 'integer'
        data.unpack("N")[0]
      when 'ipaddr'
        IPAddr.new(data, Socket::AF_INET).to_s
      when 'time'
        data.unpack("N")[0]
      when 'date'
        data.unpack("N")[0]
      else
        raise "Unknown type found: #{type}"
      end
      
      val
    end
    private :unpack_attribute
    
    def pack_attribute(data, type)
      val = case type
      when 'string'
        data
      when 'integer'
        [data].pack("N")
      when 'ipaddr'
        [IPAddr.new(data).to_i].pack("N")
      when 'date'
        [data].pack("N")
      when 'time'
        [data].pack("N")
      else
        nil
      end
      
      val
    end
    
    def unpack(data)
      @code, @identifier, @length, @authenticator, attribute_data = data.unpack(PACK_HEADER)
      @code = RESPONSES[@code]
      @attributes = Hash.new
      
      while(attribute_data.length > 0)
        # Read the length of the packet data
        length = attribute_data.unpack("xC")[0].to_i
        
        # read the type header to determine if this is a VSA
        type_id, value = attribute_data.unpack("Cxa#{length-2}")
        type_id = type_id.to_i
        
        if(type_id == VSA_TYPE)
          # Handle VSA's
          vendor_id, vendor_attribute_id, vendor_attribute_length = value.unpack("NCC")
          vendor_attribute_value = value.unpack("xxxxxxa#{vendor_attribute_length-2}")[0]
          
          # look up the type of data so we know how to unpack it
          type = @dictionary.attribute_type(vendor_id, vendor_attribute_id)
          raise "VSA not found in dictionary (#{vendor_id}/#{vendor_attribute_id})" if type.nil?
          
          val = unpack_attribute(vendor_attribute_value, type)
          set_vendor_attribute(vendor_id, vendor_attribute_id, val)
        else
          type = @dictionary.attribute_type(type_id)
          raise "Attribute not found in dictionary (#{Dictionary::DEFAULT_VENDOR}/#{type_id})" if type.nil?
          
          val = unpack_attribute(value, type)
          set_vendor_attribute(Dictionary::DEFAULT_VENDOR, type_id, val)
        end
        attribute_data[0, length] = ''
      end
    end
    
    def pack
      attr_string = ''
      
      @attributes.each_pair {|key, value|
        attr_num = @dictionary.attribute_id(key)
        type = @dictionary.attribute_type(attr_num)
        val = pack_attribute(value, type)
        next if val.nil?
        attr_string += [attr_num, val.length + 2, val].pack("CCa*")
      }
      
      rejected_responses = RESPONSES.reject{|k,v| v!=@code}
      rejected_responses = rejected_responses.to_a if RUBY_VERSION < "1.9.2"
      rcode = rejected_responses.flatten.first
      
      return [rcode, @identifier, attr_string.length + HEADER_LENGTH, @authenticator, attr_string].pack(PACK_HEADER)
    end
    
    def set_vendor_attribute(vendor_id, attr_id, value)
      attr_name = @dictionary.attribute_name(attr_id, vendor_id)
      set_attribute(attr_name, value)
    end
    
    def set_attribute(attr_name, value)
      @attributes[attr_name] = value
    end
    
    def set_password(password)
      lastround = @authenticator
      pwdout = ""
      password += "\000" * (15-(15+password.length)%16)
      0.step(password.length-1, 16) {|i|
        lastround = password[i, 16].xor(Digest::MD5.digest(@secret + lastround))
        pwdout += lastround
      }
      
      set_attribute("User-Password", pwdout)
    end
    
    def response_authenticator
      attributes = ''
      hash_data = [5, @identifier, attributes.length+HEADER_LENGTH, @authenticator, attributes, @secret].pack(PACK_HEADER)
      digest = Digest::MD5.digest(hash_data)
    end
  end
end

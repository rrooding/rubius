module Rubius
  class Dictionary
    VENDOR = 'VENDOR'
    ATTRIBUTE = 'ATTRIBUTE'
    VALUE = 'VALUE'
    DEFAULT_VENDOR = 0
    
    def initialize
      @dictionary = Hash.new
      @dictionary[DEFAULT_VENDOR] = {:name => ''}
    end
    
    def load(dictionary_file)
      dict_lines = IO.readlines(dictionary_file)
      
      vendor_id = DEFAULT_VENDOR
      skip_until_next_vendor = false
      
      dict_lines.each do |line|
        next if line =~ /^\#/
        next if (tokens = line.split(/\s+/)).empty?
        
        entry_type = tokens[0].upcase
        case entry_type
        when VENDOR
          skip_until_next_vendor = false
          
          # If the vendor_id string is nil or empty, we should skip this entire block
          # until we find another VENDOR definition, also ignore all VALUEs and ATTRIBUTEs
          # until the next VENDOR because otherwise, they will be included in the wrong VENDOR
          vendor_id_str = tokens[2]
          if vendor_id_str.nil? || vendor_id_str.empty?
            skip_until_next_vendor = true
            next
          end
          
          # VENDOR id should be higher than 0, skip everything if it isn't
          vendor_id = vendor_id_str.to_i
          if vendor_id <= 0
            skip_until_next_vendor = true
            next
          end
          
          vendor_name = tokens[1].strip
          @dictionary[vendor_id] ||= {:name => vendor_name}
        when ATTRIBUTE
          next if skip_until_next_vendor
          @dictionary[vendor_id][tokens[2].to_i] = {:name => tokens[1].strip, :type => tokens[3].strip}
        when VALUE
          next if skip_until_next_vendor
          @dictionary[vendor_id][tokens[1]] = {tokens[2].strip => tokens[3].to_i}
        end
      end
    rescue Errno::ENOENT
      raise Rubius::InvalidDictionaryError
    end
    
    def vendors
      @dictionary.collect{|k,v| v[:name]}.reject{|n| n.empty?}
    end
    
    def vendor_name(vendor_id = DEFAULT_VENDOR)
      @dictionary[vendor_id][:name]
    end
    
    def attribute_name(attr_id, vendor_id = DEFAULT_VENDOR)
      attribute(attr_id, vendor_id)[:name] rescue nil
    end
    
    def attribute_type(attr_id, vendor_id = DEFAULT_VENDOR)
      attribute(attr_id, vendor_id)[:type] rescue nil
    end
    
    def attribute_id(attr_name, vendor_id = DEFAULT_VENDOR)
      @dictionary[vendor_id].reject{|k,v| !v.is_a?(Hash) || v[:name]!=attr_name}.flatten.first
    end
    
    private
    def attribute(attr_id, vendor_id)
      @dictionary[vendor_id][attr_id] rescue nil
    end
  end
end

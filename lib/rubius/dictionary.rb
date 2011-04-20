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
      dict_lines.each do |line|
        next if line =~ /^\#/
        next if (tokens = line.split(/\s+/)).empty?
        
        entry_type = tokens[0].upcase
        case entry_type
        when VENDOR
          vendor_id = tokens[2].to_i
          vendor_name = tokens[1].strip
          @dictionary[vendor_id] ||= {:name => vendor_name}
        when ATTRIBUTE
          @dictionary[vendor_id][tokens[2].to_i] = {:name => tokens[1].strip, :type => tokens[3].strip}
        when VALUE
          @dictionary[vendor_id][tokens[1]] = {tokens[2].strip => tokens[3].to_i}
        end
      end
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

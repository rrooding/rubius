module Rubius
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.join(File.dirname(__FILE__), 'templates')
    
    def generate_install
      copy_file "rubius.yml", "config/rubius.yml"
      copy_file "rubius_initializer.rb", "config/initializers/rubius.rb"
      copy_file "radius-dictionary", "config/radius-dictionary"
    end
  end
end

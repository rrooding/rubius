module Rubius
  class Rails
    def self.init(root = nil, env = nil)
      base_dir = root
      if root.nil?
        root = defined?(Rails) ?  ::Rails.root : FileUtils.pwd
        base_dir = File.expand_path(File.join(root, 'config'))
      end
      
      if env.nil?
        env = defined?(Rails) ? ::Rails.env : 'development'
      end
      
      config_file = File.join(base_dir, 'rubius.yml')
      Rubius::Authenticator.instance.init_from_config(config_file)
    end
  end
end

require 'helper'

module Rails; end

class TestRails < Test::Unit::TestCase
  context "a Rubius::Rails.init call" do
    context "in a standalone application" do
      setup do
        Object.instance_eval{ remove_const("Rails") } if defined?(::Rails) 
      end
      
      context "without any parameters" do
        should "try to load the config file at current_dir/config/rubius.yml with the 'development' environment" do
          Rubius::Authenticator.any_instance.stubs(:init_from_config).with(File.join(FileUtils.pwd, 'config', 'rubius.yml'), 'development').returns(true)
          assert Rubius::Rails.init
        end
      end
    
      context "with path specified" do
        should "try to load the config at the specified path with the 'development' environment" do
          config_file = File.join('path', 'to', 'config')
        
          Rubius::Authenticator.any_instance.stubs(:init_from_config).with(File.join(config_file, 'rubius.yml'), 'development').returns(true)
        
          assert Rubius::Rails.init(config_file)
        end
      end
    end
    
    context "in a Rails application" do
      setup do
        ::Rails.stubs(:env).returns('stubbed')
        ::Rails.stubs(:root).returns('/home/rails')
      end
      
      should "use Rails path and environment" do
        Rubius::Authenticator.any_instance.stubs(:init_from_config).with(File.join('/', 'home', 'rails', 'config', 'rubius.yml'), 'stubbed').returns(true)
        assert Rubius::Rails.init
      end
    end
    
    context "with a non-existant configuration file" do
      should "raise an exception" do
        Rubius::Authenticator.any_instance.stubs(:init_from_config).raises(Rubius::MissingConfiguration)
        
        assert_raises Rubius::MissingConfiguration do
          Rubius::Rails.init('/bla')
        end
      end
    end
    
    context "with a configuration file thats missing the current environment" do
      should "raise an exception" do
        Rubius::Authenticator.any_instance.stubs(:init_from_config).raises(Rubius::MissingEnvironmentConfiguration)
        
        assert_raises Rubius::MissingEnvironmentConfiguration do
          Rubius::Rails.init('/bla')
        end
      end
    end 
  end
end

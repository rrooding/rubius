require 'helper'

class TestAuthenticator < Test::Unit::TestCase
  context "A Rubius::Authenticator instance" do
    setup do
      Process.stubs(:pid).returns(93354)
      
      UDPSocket.any_instance
      UDPSocket.any_instance.stubs(:addr).returns(["AF_INET", 65194, "10.1.0.45", "10.1.0.45"])
      
      @authenticator = Rubius::Authenticator.instance
    end
    
    should "generate an identifier" do
      assert_equal 170, @authenticator.instance_eval { @identifier }
    end
    
    should "increment the identifier" do
      identifier = @authenticator.instance_eval { @identifier }
      identifier += 1
      
      assert @authenticator.instance_eval { increment_identifier! }
      
      assert_equal identifier, @authenticator.instance_eval { @identifier }
    end
    
    should "overflow the identifier beyond 255" do
      @authenticator.instance_eval { @identifier = 254 }
      assert_equal 254, @authenticator.instance_eval { @identifier }
      
      assert @authenticator.instance_eval { increment_identifier! }
      assert_equal 255, @authenticator.instance_eval { @identifier }
      
      assert @authenticator.instance_eval { increment_identifier! }
      assert_equal 0, @authenticator.instance_eval { @identifier }
      
      assert @authenticator.instance_eval { increment_identifier! }
      assert_equal 1, @authenticator.instance_eval { @identifier }
    end
    
    context "supplied with a configuration file" do      
      should "read and parse the configuration file" do
        YAML.stubs(:load_file).returns(CONFIG_FILE)
        
        @authenticator.init_from_config("rubius.yml", 'development')
        assert_equal 'development-secret', @authenticator.instance_eval { @secret }
      end
      
      should "use Rails.env if env is not passed and running in a Rails application" do
        YAML.stubs(:load_file).returns(CONFIG_FILE)
        ::Rails.stubs(:env).returns('production')
        
        @authenticator.init_from_config("rubius.yml")
        assert_equal 'production-secret', @authenticator.instance_eval { @secret }
      end
      
      should "handle a non-existent config file" do
        YAML.stubs(:load_file).raises(Errno::ENOENT)
        ::Rails.stubs(:env).returns('production')
        
        assert_raises Rubius::MissingConfiguration do
          @authenticator.init_from_config("/does/not/exist/rubius.yml")
        end
      end
      
      should "handle an empty config section" do
        YAML.stubs(:load_file).returns(CONFIG_FILE)
        ::Rails.stubs(:env).returns('staging')
        
        assert_raises Rubius::MissingEnvironmentConfiguration do
          @authenticator.init_from_config("rubius.yml")
        end
      end
      
      should "setup a connection to the specified server" do
        YAML.stubs(:load_file).returns(CONFIG_FILE)
        ::Rails.stubs(:env).returns('production')
        UDPSocket.any_instance.stubs(:connect).with('10.1.0.254', 1812).returns(true)
        
        assert @authenticator.init_from_config("rubius.yml")
      end
    end
  end
end

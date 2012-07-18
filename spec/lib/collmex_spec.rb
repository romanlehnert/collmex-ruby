require 'spec_helper'
require 'yaml'
require 'collmex'

def setup_login_data
  config = YAML.load_file('config/collmex_config.yml')["development"]
  Collmex.username    = config["username"]
  Collmex.password    = config["password"]
  Collmex.customer_id = config["customer_id"]
end

describe Collmex do
  it {should respond_to :username}
  it {should respond_to :password}
  it {should respond_to :customer_id}
end




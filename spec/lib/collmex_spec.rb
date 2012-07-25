require 'spec_helper'
require 'yaml'
require 'collmex'


describe Collmex do
  it {should respond_to :username}
  it {should respond_to :password}
  it {should respond_to :customer_id}
end


describe "CollmexIntegration" do

  before(:each) do 
    setup_login_data
  end

  it "should build sample output" do
    login = Collmex::Api::Login.new({ username: Collmex.username, password: Collmex.password })
    customer_get = Collmex::Api::CustomerGet.new( {:customer_id => 9999} )
    #puts login
    #puts customer

    request = Collmex::Request.new
    request.add_command customer_get
  end

  

  


end



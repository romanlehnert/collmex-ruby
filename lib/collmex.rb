require 'collmex/api'
require 'collmex/request'

module Collmex

  class << self
    attr_accessor :customer_id
    attr_accessor :username
    attr_accessor :password
  end

  self.customer_id  = "000000"
  self.username = "000000"
  self.password = "000000"

end



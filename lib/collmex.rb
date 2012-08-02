require 'collmex/api'
require 'collmex/request'

module Collmex

  class << self

    attr_accessor :username, :password, :customer_id

    def setup_login_data(logindata)
      Collmex.username    = logindata[:username]
      Collmex.password    = logindata[:password]
      Collmex.customer_id = logindata[:customer_id]
    end

    def reset_login_data
      Collmex.username    = nil
      Collmex.password    = nil
      Collmex.customer_id = nil
    end

    def csv_opts
      {
        :col_sep => ";"
      }
    end

  end
end

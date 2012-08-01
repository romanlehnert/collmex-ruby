# Collmex-Ruby

A Ruby lib for speaking with the german accounting software collmex. 

[![Build Status](https://secure.travis-ci.org/romanlehnert/collmex-ruby.png)](http://travis-ci.org/romanlehnert/collmex-ruby)
[![Dependency Status](https://gemnasium.com/romanlehnert/collmex-ruby.png "Dependency Status")](https://gemnasium.com/romanlehnert/collmex-ruby)


## Usage

For example to get a customer and and accounting document, just enqueue the commands to the request:

    request = Collmex::Request.run do
      enqueue :customer_get, id: 9999
      enqueue :accdoc_get,   id: 1
    end

Take a look at the response:

    request.response



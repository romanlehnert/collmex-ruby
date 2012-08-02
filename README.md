# Collmex-Ruby

A Ruby lib for speaking with the german accounting software collmex. 

[![Build Status](https://secure.travis-ci.org/romanlehnert/collmex-ruby.png)](http://travis-ci.org/romanlehnert/collmex-ruby)
[![Dependency Status](https://gemnasium.com/romanlehnert/collmex-ruby.png "Dependency Status")](https://gemnasium.com/romanlehnert/collmex-ruby)


## Add it to your project

Just add it to your gemfile:

    gem "collmex-ruby"

## Configuration

In your code (in a rails-projekt you might create a config/initializers/collmex-ruby.rb) you can setup your credentials:

    Collmex.setup_login_data( username: "123456", password: "123456", customer_id: "123456" )

## Use it

For example to get a customer and and accounting document, just enqueue the commands to the request:

    request = Collmex::Request.run do
      enqueue :customer_get, id: 9999
      enqueue :accdoc_get,   id: 1
    end

Take a look at the response:

    request.response

It holds an array of all returned collmex api lines. 

## Digging deeper

### API Lines
Collmex unfortunately has a batch csv api. Everything is represented as a single line in a csv file. Here we have one object per csv line (that inherits from Collmex::Api::Line). 

#### ACCDOC_GET
ACCDOC_GET is the line that holds the query information for getting an accounting document. 



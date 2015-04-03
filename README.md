# Collmex-Ruby

A Ruby lib for speaking with the german accounting software collmex.

[![Build Status](https://secure.travis-ci.org/romanlehnert/collmex-ruby.png)](http://travis-ci.org/romanlehnert/collmex-ruby)
[![Code Climate](https://codeclimate.com/github/romanlehnert/collmex-ruby.png)](https://codeclimate.com/github/romanlehnert/collmex-ruby)
[![Dependency Status](https://gemnasium.com/romanlehnert/collmex-ruby.png)](https://gemnasium.com/romanlehnert/collmex-ruby)
[![Coverage Status](https://coveralls.io/repos/romanlehnert/collmex-ruby/badge.png)](https://coveralls.io/r/romanlehnert/collmex-ruby)
[![Gem Version](https://badge.fury.io/rb/collmex-ruby.png)](http://badge.fury.io/rb/collmex-ruby)

## Add it to your project

Just add it to your gemfile:

```ruby
gem "collmex-ruby", require: "collmex"
```

## Configuration

In your code (in a rails-project you might create a config/initializers/collmex-ruby.rb) you can setup your credentials:

```ruby
Collmex.setup_login_data( username: "123456", password: "123456", customer_id: "123456" )
```

## Use it

For example to get a customer and and accounting document, just enqueue the commands to the request:

```ruby
request = Collmex::Request.run do
  enqueue :customer_get, id: 9999
  enqueue :accdoc_get,   id: 1
end
```

Take a look at the response:

```ruby
request.response
```

It holds an array of all returned collmex api lines.


## Digging deeper

### API Lines
Collmex unfortunately has a batch csv api. Every request can hold a bunch of lines. The Documentation can be found [here](http://www.collmex.de/cgi-bin/cgi.exe?1005,1,help,api).

You can build a line by instanciating its corresponding class that inherits from Collmex::Api::Line. Under the hood, the lines are translated into
csv before we send them to collmex, or parsed from csv whn we receive them from collmex. Just give the params of the line as a hash. Every line object has a @hash property that holds the data.


#### ACCDOC_GET
For building a line object that asks for the Accountingdocument with id 1:

```ruby
accdoc_get = Collmex::Api::AccdocGet.new( id: 1 )
```

### CUSTOMER_GET
A line that asks for the customer with id: 10

```ruby
customer_get = Collmex::Api::CustomerGet.new( id: 10 )
```


### The request
A request is initiated with

```ruby
request = Collmex::Request.new
```
And you can enqueue your commands to it:

```ruby
request.enqueue Collmex::Api::AccdocGet.new(id: 1)
request.enqueue Collmex::Api::CustomerGet.new(id: 1)
```

When you have finished building your request, you can execute it:

```ruby
request.execute
```

### The response
When the request is executed, the response is parsed. Every answered line now sits as an object in our response-array:

```ruby
request.resonse.count        # number of returned lines
request.response.last.class  # Collmex::Api::Message
```

The content of a received line sits in the @hash-property of its Object.

```ruby
request.response.last.to_h    # holds the data.
```
### Sugar
You can write a request with less words by directly call the run-method and enqueue the lines inside a block (you can use symbols to identify the commands):

```ruby
request = Collmex::Request.run do
  enqueue :accdoc_get, id: 1
  enqueue :customer_get, id: 10
end
```

### Datatypes

While collmex sends and receives only strings via csv, we treat the data as ruby object.

#### Collmex String
Its represented as a string in ruby. There is no length restriction. So you have to care for yourself that collmex can handle all the contents of a Char field.

#### Collmex Float
Collmex floats are represented as floats in ruby too. You can give it a string or a integer too. When we send something to collmex in a float field, it is limited to 2 decimals.

#### Collmex Currency
Collmex has Currency as its own datatype. In ruby we use the smallest unit (cent in €) and take the amount as an integer. We have put some special parsing methods when a string should represent the alue of a currency field. Jus take a look at the spec/lib/collmex/api_spec.rb to see how we handle it.

#### Collmex Integer
Integers are the simples datatype and transparent between ruby and collmex. There is just some special handling that cares for delimiters in numbers to represent the correct value


## Authors:
This lib was originally written for [palabea](http://www.palabea.com) by roman l.



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/romanlehnert/collmex-ruby/trend.png)](https://bitdeli.com/free "Bitdeli Badge")


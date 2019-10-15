# LightServiceObject


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ensurance'  # Optional
gem 'light_service_object'
```

And then execute:

    $ bundle

## A Light Service Object with a Contract

Service objects are a great way to encapsulate business/domain functionality in a Rails app.

### The Old Way

They typically wrap some functionality up in a `call` method, with an initializer for setting parameters.

```
class TypicalServiceObject
  def initialize(date, number)
    @date = date
    @number = number
  end

  def call
    @date = Date.parse(@date) if @date.is_a?(String)
    If @date - Date.today < 7 then
      @number += 10
    else
      raise ArgumentError.new("Date is too far away")
    end
    @number
  end
end
```

This service object has a few problems:
- No indication of what it's "contract" is with the outside world
- No way to indicate failure other than Exceptions
- Manual conversion of data into the expected form

### The New Way

```
class NewServiceObject < LightServiceObject::Base
  required :date, ensure: Date
  optional :number

  def perform
    fail!("Date is too far away") if date - Date.today >= 7

    number + 10
  end
end
```

- date is required, a failure will be returned with the error message
- date will be transformed into a Date if it isn't one already `ensure: Date`
- `fail!(message)` causes the service to return a failure and message
- the last thing evaluated will be returned as the result `number + 10`
- one side note: all parameters are immutable by default

### Why is it Light?

It really is just a plain-old-ruby-object (PORO) with `Dry::Initializer` throw in with some syntax grease, and returns a `Dry::Monads::Result` -- that's it.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bsharpe/light_service_object.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

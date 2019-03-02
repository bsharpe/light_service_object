require "light_service_object/version"
require "dry/initializer"
require "dry/monads/result"

# frozen_string_literal: true

if defined?(Ensurance)
  # Define a dispatcher for `:model` option
  rails_dispatcher = ->(ensure: nil, **options) do
    # NOTE: This is because 'ensure' is a reserved word in Ruby
    klass = binding.local_variable_get(:ensure)
    return options unless klass

    begin
      klass = klass.constantize if klass.is_a?(String)
    rescue NameError => e
      msg = "LightServiceObject: #{self.class} cannot ensure(#{klass}) as the model can't be found"
      Rails.logger.error msg
      puts msg if !Rails.env.production?
      raise e
    end
    klass = klass.klass if klass.is_a?(ActiveRecord::Relation)

    coercer = ->(value) { klass.ensure(value) }
    options.merge(type: coercer)
  end

  # Register a dispatcher
  Dry::Initializer::Dispatchers << rails_dispatcher
end

module LightServiceObject
  class Base
    extend Dry::Initializer
    include Dry::Monads::Result::Mixin


    ## — CLASS METHODS
    def self.result_class
      @result_class
    end

    def self.param(key, **options)
      raise Error.new("Do not use param in a service object")
    end

    def self.required(key, **options)
      option key, **options
    end

    def self.optional(key, **options)
      options[:optional] = true
      option(key, **options)
    end

    def self.expected_result_class(klass)
      @result_class = klass
      @result_class = klass.constantize if klass.is_a?(String)
    end

    def self.call(**options)
      obj = self.new(**options)

      # Identify incoming params that weren't specified
      # set_params = obj.instance_variables.map{|e| e.to_s.tr("@","").to_sym }
      # unknown_params = (options.keys - set_params)
      # ap("#{self.name} > Unknown Parameters #{unknown_params}") if unknown_params.present?

      result = obj.call
    end

    ## — INSTANCE METHODS
    def result_class
      self.class.result_class
    end

    def call
      result = self.perform
      if self.result_class.present?
        if !result.is_a?(self.result_class)
          a_name = "#{self.result_class}"
          a_name = %w[a e i o u y].include?(a_name.first.downcase) ? "an #{a_name}" : "a #{a_name}"

          fail!("#{self.name} is not returning #{a_name}")
        end
      end
      Dry::Monads.Success(result)
    rescue StandardError => error
      reason = self.error_reason(error)
      Dry::Monads.Failure(reason)
    end

    def fail!(error)
      error = ::StandardError.new(error.to_s) if !error.is_a?(::StandardError)
      raise error
    end

    def error_reason(error)
      # Give subclasses a chance to see errors first
      "#{self}: #{error}"
    end
  end
end

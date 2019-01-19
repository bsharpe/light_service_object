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

    klass = klass.constantize if klass.is_a?(String)
    klass = klass.klass if klass.is_a?(ActiveRecord::Relation)

    coercer = ->(value) { klass.ensure(value) }
    options.merge(type: coercer)
  end

  # Register a dispatcher
  Dry::Initializer::Dispatchers << rails_dispatcher
end

module LightServiceObject
  class Error < StandardError; end

  class Base
    extend Dry::Initializer
    include Dry::Monads::Result::Mixin

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

    class << self
      attr_reader :result_class
    end

    def self.call(**options)
      obj = self.new(**options)

      # Identify incoming params that weren't specified
      # set_params = obj.instance_variables.map{|e| e.to_s.tr("@","").to_sym }
      # unknown_params = (options.keys - set_params)
      # ap("#{self.name} > Unknown Parameters #{unknown_params}") if unknown_params.present?

      result = obj.call
      if self.result_class.present?
        if !result.is_a?(self.result_class)
          a_name = "#{self.result_class}"
          a_name = %w[a e i o u y].include?(a_name.first.downcase) ? "an #{a_name}" : "a #{a_name}"

          fail!("#{self.name} is not returning #{a_name}")
        end
      end

      Dry::Monads.Success(result)
    rescue StandardError => error
      self.failed(error)
      Dry::Monads.Failure("#{self}: #{error}")
    end

    def fail!(error)
      raise (error.is_a?(String) ? Error.new(error) : error)
    end

    def self.failed(error)
      # Give subclasses a chance to see errors first
    end

    private

      def call
      end
  end
end

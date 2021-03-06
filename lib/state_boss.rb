require "state_boss/version"
require "state_boss/event_history"

module StateBoss
  include EventHistory

  class InvalidTransitionError < StandardError; end
  class StateInitializationError < StandardError; end

  def self.included(klass)
    klass.extend ClassMethods
    klass.prepend Initializer

    klass.class_eval do
      @default_state = nil
      @events = {}
      @transitions = {}
    end
  end

  def current_state
    _state
  end

  def next_states
    transitions = self.class.instance_variable_get(:@transitions)
    transitions[_state][:to]
  end

  def finished_state?
    next_states.nil?
  end

  private

  attr_reader :_state

  def ready?
    !_state.nil?
  end

  module Initializer
    def initialize(*args, &block)
      super

      @_state = self.class.instance_variable_get(:@default_state)
    end
  end

  module ClassMethods
    def state_machine(&block)
      class_eval do
        block.call
      end

      raise StateInitializationError, 'state is uninitialized.' if @default_state.nil?

      @transitions.keys.each do |key|
        define_method("#{key}?") do
          _state == key
        end
      end

      @events.keys.each do |key|
        define_method(key) do
          raise InvalidTransitionError, 'state transition finished.' if finished_state?

          events = self.class.instance_variable_get(:@events)
          to = events[key][:to]

          transitions = self.class.instance_variable_get(:@transitions)

          unless transitions[_state][:to].include?(to)
            raise InvalidTransitionError, "can't change state from #{current_state} to #{to}"
          end

          before_state = _state
          @_state = to

          begin
            callback = events[key][:callback]
            result = callback.call(self) if !callback.nil?

            record_event(before_state, key)

            result
          rescue => e
            @_state = before_state

            raise e
          end
        end
      end
    end

    def state(key, values)
      if values.key?(:as)
        if values[:as] == :default
          if @default_state
            raise InvalidTransitionError, "Already set :#{@default_state} as default state."
          end

          @default_state = key
        end

        values.merge!(to: nil) if values[:as] == :finish
      end

      @transitions[key] = values
    end

    def event(name, to:, &block)
      @events[name] = {
        to: to || [],
        callback: block,
      }
    end
  end
end

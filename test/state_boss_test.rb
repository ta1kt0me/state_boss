require "test_helper"
require "state_boss"

class StateBossTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::StateBoss::VERSION
  end

  def test_use_apis_defined_state_boss
    klass = Class.new do
      include StateBoss

      attr_accessor :mock

      def initialize(object)
        @mock = object
      end

      state_machine do
        state :first, to: [:last], as: :default
        state :last, as: :finish

        event(:to_last, to: :last) { |obj| obj.foo }
      end

      def foo; mock.call end
    end

    mock = Class.new { def call; "call" end }

    obj = klass.new(mock.new)
    assert obj.first? == true
    assert obj.last? == false
    assert obj.current_state == :first
    assert obj.next_states == [:last]
    assert obj.movable_state?(:first) == false
    assert obj.movable_state?(:last) == true
    assert obj.finished_state? == false

    assert obj.to_last == "call"
    assert obj.first? == false
    assert obj.last? == true
    assert obj.current_state == :last
    assert obj.movable_state?(:first) == false
    assert obj.movable_state?(:last) == false
    assert obj.finished_state? == true

    expected = [
      { before_state: :first, event: :to_last }
    ]
    assert obj.event_history == expected
  end
end

require "test_helper"
require "state_boss"

class StateBossTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::StateBoss::VERSION
  end

  def test_current_state
    monster = charmander_class.new
    assert_equal monster.current_state, :charmander

    monster.evolve_first
    assert_equal monster.current_state, :charmeleon

    monster.evolve_second
    assert_equal monster.current_state, :charizard
  end

  def test_next_states
    monster = eevee_class.new
    assert_equal monster.next_states, [:jolteon, :vaporeon, :flareon]
  end

  def test_finished_state?
    monster = eevee_class.new
    assert_nil monster.water_stone
    assert_equal monster.finished_state?, true
  end

  def test_events
    monster = chansey_class.new(100)

    assert_equal monster.alive?, true
    assert_equal monster.fainting?, false
    assert_equal monster.pokemon_shock, 0
    assert_equal monster.alive?, false
    assert_equal monster.fainting?, true
    assert_equal monster.pokemon_center, 100
  end

  def test_event_history
    monster = chansey_class.new(100)
    monster.pokemon_shock
    monster.pokemon_center

    expected = [
      { before_state: :alive, event: :pokemon_shock },
      { before_state: :fainting, event: :pokemon_center }
    ]

    assert monster.event_history, expected
  end

  def test_state_initialization_error
    assert_raises(StateBoss::StateInitializationError) do
      Class.new {
        include StateBoss

        state_machine do
          state :walking, to: :flying
          state :flying, as: :finish
        end
      }
    end
  end

  def test_mismatch_to_state
    ketsuban = Class.new {
      include StateBoss

      state_machine do
        state :walking, to: [:flying], as: :default
        state :flying, to: [:surfing]
        state :surf, to: [:walking]

        event :fly, to: :surfing
      end
    }.new

    assert_raises(StateBoss::InvalidTransitionError) do
      ketsuban.fly
    end
  end

  def test_default_state_twice
    assert_raises(StateBoss::InvalidTransitionError) do
      Class.new {
        include StateBoss

        state_machine do
          state :walking, as: :default
          state :flying, as: :default
        end
      }
    end
  end

  def test_change_finieshed_state
    ketsuban = Class.new {
      include StateBoss

      state_machine do
        state :walking, to: [:flying], as: :default
        state :flying, as: :finish

        event(:fly, to: :flying)
      end
    }.new

    ketsuban.fly

    assert_raises(StateBoss::InvalidTransitionError) do
      ketsuban.fly
    end
  end

  def test_rollback_state_in_error
    ketsuban = Class.new {
      include StateBoss

      state_machine do
        state :walking, to: [:flying], as: :default
        state :flying, as: :finish

        event(:fly, to: :flying) { raise RuntimeError }
      end
    }.new

    assert_raises(RuntimeError) do
      ketsuban.fly
    end

    assert_equal ketsuban.walking?, true
  end

  private

  def charmander_class
    Class.new do
      include StateBoss

      state_machine do
        state :charmander, to: [:charmeleon], as: :default
        state :charmeleon, to: [:charizard]
        state :charizard, as: :finish

        event :evolve_first, to: :charmeleon
        event :evolve_second, to: :charizard
      end
    end
  end

  def eevee_class
    Class.new do
      include StateBoss

      state_machine do
        state :eevee, to: [:jolteon, :vaporeon, :flareon], as: :default
        state :jolteon, as: :finish
        state :vaporeon, as: :finish
        state :flareon, as: :finish

        event :water_stone, to: :vaporeon
        event :thunder_stone, to: :jolteon
        event :fire_stone, to: :flareon
      end
    end
  end

  def chansey_class
    Class.new do
      include StateBoss

      attr_writer :life

      def initialize(life)
        @life = life
      end

      state_machine do
        state :alive, to: [:fainting], as: :default
        state :fainting, to: [:alive]

        event(:pokemon_shock, to: :fainting) { |object| object.life = 0 }
        event(:pokemon_center, to: :alive) { |object| object.life = 100 }
      end
    end
  end
end

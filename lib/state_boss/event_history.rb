module StateBoss
  module EventHistory
    def event_history
      _event_history
    end

    def record_event(before_state, event)
      @_event_history = (_event_history || []) << {
        before_state: before_state,
        event: event,
      }
    end

    private

    def _event_history
      if defined?(@_event_history)
        @_event_history
      else
        @_event_history = []
      end
    end
  end
end

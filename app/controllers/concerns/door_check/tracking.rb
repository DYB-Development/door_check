module DoorCheck
  module Tracking
    SESSION_KEY = :door_check_session_id

    def door_check_signed_in(person, method_name:)
      signed_in_session = SignedInSession.create!(person: person)
      signed_in_session.prove!(method_name)
      session[SESSION_KEY] = signed_in_session.id
    end

    def door_check_proved_by
      door_check_session&.proved_by || []
    end

    private

    def door_check_session
      SignedInSession.find_by(id: session[SESSION_KEY])
    end
  end
end

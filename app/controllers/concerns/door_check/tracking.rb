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

    def door_check_account
      account_method = DoorCheck.configuration.account_method
      send(account_method) if account_method
    end

    private

    def door_check_session
      person = door_check_person
      SignedInSession.find_by(id: session[SESSION_KEY], person: person) if person
    end

    def door_check_person
      send(DoorCheck.configuration.person_method)
    end
  end
end

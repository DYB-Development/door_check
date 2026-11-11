module DoorCheck
  module EntryCheck
    RETURN_KEY = :door_check_return_to

    def door_check_check_entry
      door_check_session&.note_use
      return if door_check_entry_met?

      session[RETURN_KEY] = request.fullpath
      redirect_to door_check.new_second_step_path
    end

    private

    def door_check_entry_met?
      person = door_check_person
      return true if person.nil?

      proved = door_check_proved_by.map(&:first)
      proved += [ :trusted_device ] if door_check_trusted_browser?(person)
      account = door_check_account
      PersonRule.for(person).met_by?(proved) && (account.nil? || AccountRule.for(account).met_by?(proved))
    end

    def door_check_trusted_browser?(person)
      token = cookies.signed[TrustedDevice::COOKIE]
      DoorCheck.configuration.offered_methods.include?(:trusted_device) && token.present? && TrustedDevice.recognise(person, token).present?
    end
  end
end

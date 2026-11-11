module DoorCheck
  module EntryCheck
    RETURN_KEY = :door_check_return_to

    def door_check_check_entry
      account = door_check_account
      return if account.nil? || AccountRule.for(account).met_by?(door_check_proved_by.map(&:first))

      session[RETURN_KEY] = request.fullpath
      redirect_to door_check.new_second_step_path
    end
  end
end

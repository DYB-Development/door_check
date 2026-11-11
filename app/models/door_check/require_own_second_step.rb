module DoorCheck
  class RequireOwnSecondStep
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      PersonRule.for(@person).update!(second_step_required: @values[:second_step_required] == "1")
      Result.new(ok: true)
    end
  end
end

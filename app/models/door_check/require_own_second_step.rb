module DoorCheck
  class RequireOwnSecondStep
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      return Result.new(ok: false, message: "This app decides when you are asked for a second step.") unless DoorCheck.configuration.people_choose_second_step

      PersonRule.for(@person).update!(second_step_required: @values[:second_step_required] == "1")
      Result.new(ok: true)
    end
  end
end

module DoorCheck
  class RequireOwnSecondStep
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      return Result.new(ok: false, message: refusal) unless PersonRule.for(@person).may_choose_in?(@account)

      PersonRule.for(@person).update!(second_step_required: @values[:second_step_required] == "1")
      Result.new(ok: true)
    end

    private

    def refusal
      return "This app decides when you are asked for a second step." unless DoorCheck.configuration.people_choose_second_step

      "Your account decides whether you are asked for a second step."
    end
  end
end

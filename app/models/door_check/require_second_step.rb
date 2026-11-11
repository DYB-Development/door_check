module DoorCheck
  class RequireSecondStep
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      return Result.new(ok: false, message: "Pick only methods this app offers.") if picks_unoffered_method?

      AccountRule.for(@account).update!(second_step_required: @values[:second_step_required] == "1", accepted_methods: @values[:accepted_methods])
      Result.new(ok: true)
    end

    private

    def picks_unoffered_method?
      picked = Array(@values[:accepted_methods]).map(&:to_sym)
      (picked - DoorCheck.configuration.offered_methods).any?
    end
  end
end

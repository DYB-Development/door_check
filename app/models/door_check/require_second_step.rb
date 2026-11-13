module DoorCheck
  class RequireSecondStep
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      return Result.new(ok: false, message: "Pick only methods this app offers.") if picks_unoffered_method?
      return Result.new(ok: false, message: "This app decides when members are asked for a second step.") if sets_forbidden_members_choice?

      AccountRule.for(@account).update!(saved_values)
      Result.new(ok: true)
    end

    private

    def saved_values
      saved = { second_step_required: @values[:second_step_required] == "1", accepted_methods: @values[:accepted_methods] }
      saved[:members_choose_second_step] = @values[:members_choose_second_step] == "1" if @values.key?(:members_choose_second_step)
      saved
    end

    def sets_forbidden_members_choice?
      @values.key?(:members_choose_second_step) && !DoorCheck.configuration.people_choose_second_step
    end

    def picks_unoffered_method?
      picked = Array(@values[:accepted_methods]).map(&:to_sym)
      (picked - DoorCheck.configuration.offered_methods).any?
    end
  end
end

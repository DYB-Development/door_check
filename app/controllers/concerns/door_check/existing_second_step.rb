module DoorCheck
  module ExistingSecondStep
    extend ActiveSupport::Concern

    included do
      before_action :ask_for_existing_second_step
    end

    private

    def ask_for_existing_second_step
      return unless SecondStep.set_up?(door_check_person)
      return if door_check_proved_by.any? { |method_name, _| Methods.roles(method_name).include?(:second_step) }

      session[EntryCheck::RETURN_KEY] = request.get? ? request.fullpath : request.referer
      redirect_to door_check.new_second_step_path
    end
  end
end

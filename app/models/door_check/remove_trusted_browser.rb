module DoorCheck
  class RemoveTrustedBrowser
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      TrustedDevice.where(person: @person).find_by(id: @values[:trusted_device_id])&.destroy!
      Result.new(ok: true)
    end
  end
end

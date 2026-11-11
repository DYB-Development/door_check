module DoorCheck
  class RemoveMethod
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      Credential.where(person: @person).find_by(id: @values[:credential_id])&.destroy!
      Result.new(ok: true)
    end
  end
end

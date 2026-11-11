module DoorCheck
  class SignOutSession
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      SignedInSession.where(person: @person, signed_out_at: nil).find_by(id: @values[:signed_in_session_id])&.update!(signed_out_at: Time.current)
      Result.new(ok: true)
    end
  end
end

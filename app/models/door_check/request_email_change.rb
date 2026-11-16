module DoorCheck
  class RequestEmailChange
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      Result.new(ok: true)
    end
  end
end

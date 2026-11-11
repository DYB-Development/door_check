module DoorCheck
  class Result
    attr_reader :message

    def initialize(ok:, message: nil)
      @ok = ok
      @message = message
    end

    def ok? = @ok
  end
end

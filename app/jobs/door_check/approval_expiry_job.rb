module DoorCheck
  class ApprovalExpiryJob < ApplicationJob
    queue_as :default

    def perform(challenge)
      Turbo::StreamsChannel.broadcast_refresh_to(challenge)
    end
  end
end

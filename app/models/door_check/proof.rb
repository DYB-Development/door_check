module DoorCheck
  class Proof < ApplicationRecord
    belongs_to :signed_in_session
  end
end

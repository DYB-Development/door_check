module DoorCheck
  class SignedInSession < ApplicationRecord
    belongs_to :person, polymorphic: true
    has_many :proofs, dependent: :delete_all

    def prove!(method_name)
      proofs.create!(method_name: method_name, proved_at: Time.current)
    end

    def proved_by
      proofs.order(:proved_at).map { |proof| [ proof.method_name.to_sym, proof.proved_at ] }
    end
  end
end

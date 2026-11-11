module DoorCheck
  class SignedInSession < ApplicationRecord
    belongs_to :person, polymorphic: true
    has_many :proofs, dependent: :delete_all

    def prove!(method_name)
      proofs.create!(method_name: method_name, proved_at: Time.current)
    end

    def last_used = last_used_at&.to_fs(:long)

    def note_use
      update_column(:last_used_at, Time.current) if last_used_at.nil? || last_used_at < 5.minutes.ago
    end

    def proved_by
      proofs.order(:proved_at).map { |proof| [ proof.method_name.to_sym, proof.proved_at ] }
    end
  end
end

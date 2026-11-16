module DoorCheck
  class Challenge < ApplicationRecord
    LIFETIME = 15.minutes
    APPROVAL_LIFETIME = 5.minutes
    CONFIRMATION_LIFETIME = 24.hours

    belongs_to :person, polymorphic: true

    attr_accessor :code, :token

    scope :awaiting_approval, -> { where.not(number: nil).where(approved_at: nil, declined_at: nil, used_at: nil).where("expires_at > ?", Time.current) }

    def self.issue(person, email: nil)
      code = format("%06d", SecureRandom.random_number(1_000_000))
      token = SecureRandom.urlsafe_base64(32)
      create!(person: person, email: email, code: code, token: token, code_digest: digest(code), token_digest: digest(token), expires_at: LIFETIME.from_now)
    end

    def self.issue_confirmation(person, email) = issue_link(person, email, purpose: "confirm")

    def self.issue_email_change(person, email) = replace_link(person, email, purpose: "change_email")

    def self.issue_email_change_cancel(person, email) = replace_link(person, email, purpose: "cancel_email_change")

    def self.issue_link(person, email, purpose:)
      token = SecureRandom.urlsafe_base64(32)
      create!(person: person, email: email, purpose: purpose, token: token, token_digest: digest(token), expires_at: CONFIRMATION_LIFETIME.from_now)
    end
    private_class_method :issue_link

    def self.replace_link(person, email, purpose:)
      where(person: person, purpose: purpose, used_at: nil).update_all(used_at: Time.current)
      issue_link(person, email, purpose: purpose)
    end
    private_class_method :replace_link

    def self.end_unused(person, email, purpose:)
      where(person: person, email: email, purpose: purpose, used_at: nil).update_all(used_at: Time.current)
    end

    def self.request_approval(person, device:, ip_address:)
      create!(person: person, number: format("%02d", SecureRandom.random_number(10..99)), device: device, ip_address: ip_address,
              expires_at: APPROVAL_LIFETIME.from_now).tap do |challenge|
        Turbo::StreamsChannel.broadcast_refresh_to(person, :door_check_approvals)
        ApprovalExpiryJob.set(wait_until: challenge.expires_at).perform_later(challenge)
      end
    end

    def self.digest(value) = KeyedDigest.of(value)

    def self.for_token(token, purpose:) = find_by(token_digest: digest(token), purpose: purpose)

    def self.redeem_token(token, purpose: "sign_in")
      challenge = for_token(token, purpose: purpose)
      challenge if challenge&.use
    end

    def confirm_address
      EmailConfirmation.for(person).confirm(email)
    end

    def approve
      update!(approved_at: Time.current)
      Turbo::StreamsChannel.broadcast_refresh_to(self)
    end

    def decline
      update!(declined_at: Time.current)
      Turbo::StreamsChannel.broadcast_refresh_to(self)
    end

    def approved? = approved_at.present?

    def declined? = declined_at.present?

    def expired? = expires_at <= Time.current

    def location
      lookup = DoorCheck.configuration.locate_ip
      lookup ? lookup.call(ip_address) : ip_address
    end

    def redeem_code(code)
      ActiveSupport::SecurityUtils.secure_compare(code_digest, self.class.digest(code)) && use
    end

    def use
      self.class.where(id: id, used_at: nil).where("expires_at > ?", Time.current).update_all(used_at: Time.current) == 1
    end
  end
end

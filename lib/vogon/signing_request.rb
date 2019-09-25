# frozen_string_literal: true

module Vogon
  class SigningRequest
    include ActiveModel::Validations

    DAY_SECONDS = 86_400

    attr_accessor :csr, :valid_days
    attr_reader :valid_from, :valid_to

    validate :valid_valitidy_duration

    def initialize(csr, valid_days)
      self.csr = csr
      self.valid_days = valid_days

      @valid_from = Time.now.utc
      @valid_to = valid_from + (valid_days * SigningRequest::DAY_SECONDS)
    end

    def sign(signatory)
      to_cert.tap do |cert|
        cert.issuer = signatory.issuer
        cert.signature = signatory.sign(csr)
      end
    end

    private

    def to_cert
      Vogon::Containers::Certificate.new(
        serial_number: 16_019_012_157_061_550_576,
        signing_alg: "RSA-SHA256",
        validity: { from: valid_from, to: valid_to },
        subject: csr.subject,
        subject_public_key: csr.subject_public_key
      )
    end

    def valid_valitidy_duration
      return if valid_days <= 180

      errors.add(:valid_days, "must be less than 180")
    end
  end
end

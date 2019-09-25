# frozen_string_literal: true

require "base64"
require "openssl"
require "pry"

require "signer/containers/certificate"
require "signer/containers/request"
require "signer/signatories/local"
require "signer/signatories/azure_key_vault"
require "signer/version"

module Signer
  DAY_SECONDS = 86_400

  def self.sign(csr, signatory, valid_days)
    csr = Signer::Containers::Request.new csr

    signature = signatory.sign(csr)
    valid_from = Time.now.utc
    valid_to = valid_from + (valid_days * Signer::DAY_SECONDS)

    # TODO: Manage serial number generation.
    Signer::Containers::Certificate.new(
      serial_number: 16_019_012_157_061_550_576,
      signing_alg: "RSA-SHA256",
      issuer: signatory.issuer,
      validity: {
        from: valid_from,
        to: valid_to
      },
      subject: csr.subject,
      subject_public_key: csr.subject_public_key,
      signature: signature
    )
  end
end

# frozen_string_literal: true

require "openssl"
require "pry"

require "signer/containers/certificate"
require "signer/containers/request"
require "signer/signatories/local"
require "signer/version"

module Signer
  def self.sign(csr_file, signatory)
    csr = Signer::Containers::Request.new File.read csr_file

    signature = signatory.sign(csr)

    # TODO: Manage serial number generation.
    Signer::Containers::Certificate.new(
      serial_number: 16_019_012_157_061_550_576,
      signing_alg: "RSA-SHA256",
      issuer: signatory.issuer,
      validity: {
        from: Time.utc(2019, 9, 24, 14, 25, 23),
        to: Time.utc(2021, 2, 5, 14, 25, 23)
      },
      subject: csr.subject,
      subject_public_key: csr.subject_public_key,
      signature: signature
    )
  end
end

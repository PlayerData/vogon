# frozen_string_literal: true

require "openssl"
require "pry"

require "signer/containers/certificate"
require "signer/containers/request"
require "signer/version"

class Signer
  def self.sign(csr_file, ca_key_file, ca_cert_file)
    csr = Signer::Containers::Request.new File.read csr_file

    ca_key = OpenSSL::PKey::RSA.new(File.read(ca_key_file))
    ca_cert = Signer::Containers::Certificate.from_bytes File.read(ca_cert_file)

    digest = OpenSSL::Digest::SHA256.new
    signature = ca_key.sign(digest, csr.to_der)

    # TODO: Manage serial number generation.
    signed_cert = Signer::Containers::Certificate.new(
      serial_number: 16_019_012_157_061_550_576,
      signing_alg: "RSA-SHA256",
      issuer: ca_cert.subject,
      validity: {
        from: Time.utc(2019, 9, 24, 14, 25, 23),
        to: Time.utc(2021, 2, 5, 14, 25, 23)
      },
      subject: csr.subject,
      subject_public_key: csr.subject_public_key,
      signature: signature
    )

    File.open("/tmp/output.der", "wb") { |file| file.write signed_cert.to_der }

    signed_cert
  end
end

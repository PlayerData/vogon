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
    ca_cert = Signer::Containers::Certificate.new File.read(ca_cert_file)

    digest = OpenSSL::Digest::SHA256.new
    signature = ca_key.sign(digest, csr.to_der)

    # TODO: Manage serial number generation.
    serial_number = OpenSSL::ASN1::Integer.new(16_019_012_157_061_550_576, 2)
    signing_alg = OpenSSL::ASN1::Sequence.new(
      [
        OpenSSL::ASN1::ObjectId.new("RSA-SHA256", 6),
        OpenSSL::ASN1::Null.new(nil)
      ]
    )
    issuer = ca_cert.subject
    validity = OpenSSL::ASN1::Sequence.new(
      [
        OpenSSL::ASN1::UTCTime.new(Time.utc(2019, 9, 24, 14, 25, 23), 23),
        OpenSSL::ASN1::UTCTime.new(Time.utc(2021, 2, 5, 14, 25, 23), 23)
      ]
    )
    subject = csr.subject
    subject_public_key = csr.subject_public_key

    tbs_cert = OpenSSL::ASN1::Sequence.new(
      [
        serial_number,
        signing_alg,
        issuer,
        validity,
        subject,
        subject_public_key
      ]
    )

    signature = OpenSSL::ASN1::BitString.new(signature, 3)

    signed_cert = OpenSSL::ASN1::Sequence.new([tbs_cert, signing_alg, signature])

    File.open("/tmp/output.der", "wb") { |file| file.write signed_cert.to_der }

    signed_cert
  end
end

# frozen_string_literal: true

require "openssl"
require "pry"

class Signer
  def self.sign
    csr = OpenSSL::X509::Request.new File.read "example.csr"
    csr_asn = OpenSSL::ASN1.decode(csr)

    ca_key = OpenSSL::PKey::RSA.new(File.read("rootCA.key"))
    ca_cert = OpenSSL::X509::Certificate.new(File.read("rootCA.crt"))
    ca_asn = OpenSSL::ASN1.decode(ca_cert)

    digest = OpenSSL::Digest::SHA256.new
    signature = ca_key.sign(digest, csr.to_der)

    # TODO: Manage serial number generation.
    serial_number = OpenSSL::ASN1::Integer.new(1, 2)
    signing_alg = OpenSSL::ASN1::Sequence.new(
      [
        OpenSSL::ASN1::ObjectId.new("RSA-SHA256", 6),
        OpenSSL::ASN1::Null.new(nil)
      ]
    )
    issuer = ca_asn.value[0].value[4]
    validity = OpenSSL::ASN1::Sequence.new(
      [
        OpenSSL::ASN1::UTCTime.new(Time.utc(2019, 9, 24, 13, 0, 0), 23),
        OpenSSL::ASN1::UTCTime.new(Time.utc(2020, 9, 24, 13, 0, 0), 23)
      ]
    )
    subject = csr_asn.value[0].value[1]
    subject_public_key = csr_asn.value[0].value[2]

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

    File.open("output.der", "wb") { |file| file.write signed_cert.to_der }

    return signed_cert
  end
end

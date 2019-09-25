# frozen_string_literal: true

RSpec.describe Vogon::SigningRequest do
  it "signs a CSR" do
    ca_cert = OpenSSL::X509::Certificate.new(File.read(fixture("ca.crt")))
    signatory = Vogon::Signatories::Local.new(
      ca_key_file: fixture("ca.key"), ca_cert_file: fixture("ca.crt")
    )

    csr = Vogon::Containers::Request.new File.read(fixture("example.csr"))
    request = Vogon::SigningRequest.new(csr, 180)

    output_der = request.sign(signatory)
    output_cert = OpenSSL::X509::Certificate.new(output_der)

    expect(output_cert.verify(ca_cert.public_key))

    expect(output_cert.subject.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-csr/emailAddress=dev@playerdata.co.uk"
    )

    expect(output_cert.issuer.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-ca/emailAddress=dev@playerdata.co.uk"
    )
  end

  it "validates that the length is not more than 180 days" do
    csr = Vogon::Containers::Request.new File.read(fixture("example.csr"))
    request = Vogon::SigningRequest.new(csr, 181)

    expect(request).to be_invalid
    expect(request.errors[:valid_days]).to include "must be less than 180"
  end
end

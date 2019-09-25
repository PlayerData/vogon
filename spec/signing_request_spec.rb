# frozen_string_literal: true

RSpec.describe Vogon::SigningRequest do
  it "signs a CSR" do
    Timecop.freeze(Time.utc(2019, 9, 25, 13, 27, 43))

    ca_cert = OpenSSL::X509::Certificate.new(File.read(fixture("ca.crt")))
    signatory = Vogon::Signatories::Local.new(
      ca_key_file: fixture("ca.key"), ca_cert_file: fixture("ca.crt")
    )

    csr = Vogon::Containers::Request.new File.read(fixture("example.csr"))
    request = Vogon::SigningRequest.new(csr, 90)

    output_der = request.sign(signatory)
    output_cert = OpenSSL::X509::Certificate.new(output_der)

    expect(output_cert.verify(ca_cert.public_key))

    expect(output_cert.subject.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-csr/emailAddress=dev@playerdata.co.uk"
    )

    expect(output_cert.issuer.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-ca/emailAddress=dev@playerdata.co.uk"
    )

    expect(output_cert.serial).to eq 1_569_418_063
    expect(output_cert.not_before).to eq Time.utc(2019, 9, 25, 13, 27, 43)
    expect(output_cert.not_after).to eq Time.utc(2019, 12, 24, 13, 27, 43)
  end

  it "validates that the length is not more than 180 days" do
    csr = Vogon::Containers::Request.new File.read(fixture("example.csr"))
    request = Vogon::SigningRequest.new(csr, 181)

    expect(request).to be_invalid
    expect(request.errors[:valid_days]).to include "must be less than 180"
  end
end

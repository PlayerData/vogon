# frozen_string_literal: true

RSpec.describe Signer do
  it "signs a CSR" do
    ca_cert = OpenSSL::X509::Certificate.new(File.read(fixture("ca.crt")))
    signatory = Signer::Signatories::Local.new(
      ca_key_file: fixture("ca.key"), ca_cert_file: fixture("ca.crt")
    )

    output_der = Signer.sign(File.read(fixture("example.csr")), signatory, 180)
    output_cert = OpenSSL::X509::Certificate.new(output_der)

    expect(output_cert.verify(ca_cert.public_key))

    expect(output_cert.subject.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-csr/emailAddress=dev@playerdata.co.uk"
    )

    expect(output_cert.issuer.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-ca/emailAddress=dev@playerdata.co.uk"
    )
  end
end

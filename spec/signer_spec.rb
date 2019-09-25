# frozen_string_literal: true

RSpec.describe Signer do
  it "signs the certificate" do
    Signer.sign(fixture("example.csr"), fixture("ca.key"), fixture("ca.crt"))

    ca_cert = OpenSSL::X509::Certificate.new(File.read(fixture("ca.crt")))
    output_cert = OpenSSL::X509::Certificate.new(File.read("/tmp/output.der"))

    expect(output_cert.verify(ca_cert.public_key))

    expect(output_cert.subject.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-csr/emailAddress=dev@playerdata.co.uk"
    )

    expect(output_cert.issuer.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-ca/emailAddress=dev@playerdata.co.uk"
    )
  end

  def fixture(path)
    File.join(__dir__, "fixtures/#{path}")
  end
end

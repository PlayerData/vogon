# frozen_string_literal: true

require_relative "./signer"

RSpec.describe Signer do
  it "signs the certificate" do
    Signer.sign

    ca_cert = OpenSSL::X509::Certificate.new(File.read("./rootCA.crt"))
    output_cert = OpenSSL::X509::Certificate.new(File.read("./output.der"))

    expect(output_cert.verify(ca_cert.public_key))
    expect(output_cert.subject.to_s).to eq "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd"
    expect(output_cert.issuer.to_s).to eq "/C=GB"
  end
end

# frozen_string_literal: true

require_relative "./signer"

RSpec.describe Signer do
  it "signs the certificate" do
    fixture_cert = OpenSSL::ASN1.decode(File.read("./example.crt.der"))

    Signer.sign

    output_cert = OpenSSL::ASN1.decode(File.read("./output.der"))

    expect(output_cert).to eq fixture_cert
  end
end

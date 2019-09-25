# frozen_string_literal: true

RSpec.describe Signer::Containers::Certificate do
  it "converts to der" do
    example_crt = OpenSSL::X509::Certificate.new File.read(fixture("ca.crt"))
    example_asn = OpenSSL::ASN1.decode(example_crt)

    signer_cert = Signer::Containers::Certificate.new(
      serial_number: 15_091_708_261_823_859_145,
      signing_alg: "RSA-SHA256",
      issuer: example_asn.value[0].value[4],
      validity: {
        from: Time.utc(2019, 9, 25, 8, 9, 20),
        to: Time.utc(2029, 9, 22, 8, 9, 20)
      },
      subject: example_asn.value[0].value[2],
      subject_public_key: example_asn.value[0].value[5],
      signature: example_asn.value[2].value
    )

    expect(signer_cert.to_der).to eq example_asn.to_der
  end

  it "converts to pem" do
    expect(
      Signer::Containers::Certificate.from_bytes(File.read(fixture("ca.crt"))).to_pem
    ).to eq File.read(fixture("ca.crt"))
  end
end

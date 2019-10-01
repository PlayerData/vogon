# frozen_string_literal: true

RSpec.describe Vogon::Signatories::Local do
  subject(:signatory) do
    Vogon::Signatories::Local.new(
      ca_key_file: fixture("ca.key"),
      ca_cert_file: fixture("ca.crt")
    )
  end

  it "gets the issuer name" do
    ca_cert = OpenSSL::X509::Certificate.new File.read(fixture("ca.crt"))

    expect(signatory.issuer.to_der).to eq ca_cert.subject.to_der
  end

  it "signs a TBS cert" do
    csr = Vogon::Containers::Request.new File.read(fixture("example.csr"))

    cert = Vogon::Containers::Certificate.new(
      serial_number: 1,
      signing_alg: "RSA-SHA256",
      issuer: csr.subject,
      validity: {
        from: Time.utc(2019, 9, 25, 8, 9, 20),
        to: Time.utc(2029, 9, 22, 8, 9, 20)
      },
      subject: csr.subject,
      subject_public_key: csr.subject_public_key
    )

    expect(Base64.encode64(signatory.sign(cert.tbs_der))).to eq(
      <<~SIGNATURE
        DUeBq2UlAhe9eeZVyPeRQ3L3BGuFTNLht+tgPXr+wLzuO7uXp94GiWTJEm4t
        4tdI8ODI1djRzTr8hAujq70tR1hlMbEB5aM/vkryqkwAU9NEoX2mSRAIOTwl
        4ypQxpyFpXrmyf47d6AgrporQwQaJES0QID9qSvwtnKlcG5s8KM18nJU93fj
        3RsbG68MyfZrk2t7FWXtkbWbrlVwWzUG4e5DzFlG+70D6qLYZr5PrFgKvoUD
        3dTP6yUnyYyPoU3XvROiheLEEHMwe649cGBhJ41e3MxmXizi7fR9Afhj3OgH
        NSRfED2jGWipXRyLW7hz50ADJuHqFw4v5tb/GDg5DQ==
      SIGNATURE
    )
  end
end

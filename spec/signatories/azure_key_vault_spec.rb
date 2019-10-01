# frozen_string_literal: true

require "base64"

RSpec.describe Vogon::Signatories::AzureKeyVault, :vcr do
  let(:ca_cert) { OpenSSL::X509::Certificate.new File.read(fixture("ca.crt")) }

  shared_examples "Vogon AzureKeyVault Signatory" do
    it "fetches the CA certificate" do
      expect(signatory.ca_certificate.subject.to_der).to eq ca_cert.subject.to_der
    end

    it "gets the issuer name" do
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

  describe "using tenant_id, client_id, and client_secret to perform the OAuth dance" do
    subject(:signatory) do
      Vogon::Signatories::AzureKeyVault.new(
        base_url: "https://vogon-development.vault.azure.net",
        certificate_name: "vogon-test",
        tenant_id: "73081428-e0d9-4468-ad4c-c89aec3a6f35",
        client_id: ENV["AZURE_KEY_VAULT_CLIENT_ID"],
        client_secret: ENV["AZURE_KEY_VAULT_CLIENT_SECRET"]
      )
    end

    it_behaves_like "Vogon AzureKeyVault Signatory"

    it "raises a sensible error if fetching an access token fails" do
      signatory = Vogon::Signatories::AzureKeyVault.new(
        base_url: "https://vogon-development.vault.azure.net",
        certificate_name: "vogon-test",
        tenant_id: "73081428-e0d9-4468-ad4c-c89aec3a6f35",
        client_id: "",
        client_secret: ""
      )

      expect { signatory.ca_certificate }.to raise_error.with_message(/"error":"invalid_client"/)
    end
  end

  describe "using access_token" do
    subject(:signatory) do
      Vogon::Signatories::AzureKeyVault.new(
        base_url: "https://vogon-development.vault.azure.net",
        certificate_name: "vogon-test",
        access_token: ENV["AZURE_KEY_VAULT_ACCESS_TOKEN"] || "<ACCESS_TOKEN>"
      )
    end

    it_behaves_like "Vogon AzureKeyVault Signatory"
  end
end

# frozen_string_literal: true

require "signer/server"

RSpec.describe "/sign" do
  include Rack::Test::Methods

  let(:ca_cert) { OpenSSL::X509::Certificate.new(File.read(fixture("ca.crt"))) }

  before do
    ENV["SIGNER_SERVER_CONFIG"] = fixture("server_config.yml")
  end

  it "signs a CSR using the local signatory" do
    Timecop.freeze(Time.utc(2019, 9, 25, 13, 27, 43))

    csr = File.read(fixture("example.csr"))
    post "/sign?signatory=Local&days=180", csr

    expect(last_response).to be_ok
    output_cert = OpenSSL::X509::Certificate.new last_response.body

    expect(output_cert.verify(ca_cert.public_key))
    expect(output_cert.subject.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-csr/emailAddress=dev@playerdata.co.uk"
    )
    expect(output_cert.issuer.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-ca/emailAddress=dev@playerdata.co.uk"
    )

    expect(output_cert.not_before).to eq Time.utc(2019, 9, 25, 13, 27, 43)
    expect(output_cert.not_after).to eq Time.utc(2020, 3, 23, 13, 27, 43)
  end

  it "signs a CSR using the AKV signatory", :vcr do
    Timecop.freeze(Time.utc(2019, 9, 25, 13, 27, 43))

    csr = File.read(fixture("example.csr"))
    post "/sign?signatory=AzureKeyVault&days=90" \
      "&azure_key_vault_client_id=#{ENV['AZURE_KEY_VAULT_CLIENT_ID']}" \
      "&azure_key_vault_client_secret=#{ENV['AZURE_KEY_VAULT_CLIENT_SECRET']}", csr

    expect(last_response).to be_ok
    output_cert = OpenSSL::X509::Certificate.new last_response.body

    expect(output_cert.verify(ca_cert.public_key))
    expect(output_cert.subject.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-csr/emailAddress=dev@playerdata.co.uk"
    )
    expect(output_cert.issuer.to_s).to eq(
      "/C=GB/ST=Edinburgh/L=Edinburgh/O=PlayerData Ltd/CN=signer-test-ca/emailAddress=dev@playerdata.co.uk"
    )

    expect(output_cert.not_before).to eq Time.utc(2019, 9, 25, 13, 27, 43)
    expect(output_cert.not_after).to eq Time.utc(2019, 12, 24, 13, 27, 43)
  end

  it "fails if days > 180"

  it "fails if the signatory is not whitelisted"

  def app
    Signer::Server
  end
end

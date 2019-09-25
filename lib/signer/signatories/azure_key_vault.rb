# frozen_string_literal: true

require "httparty"

module Signer
  module Signatories
    class AzureKeyVault
      include HTTParty

      attr_accessor :base_url, :certificate_name, :tenant_id, :client_id, :client_secret

      def initialize
        self.base_url = ENV["AZURE_KEY_VAULT_BASE_URL"]
        self.certificate_name = ENV["AZURE_KEY_VAULT_CERTIFICATE_NAME"]
        self.tenant_id = ENV["AZURE_TENANT_ID"]
        self.client_id = ENV["AZURE_CLIENT_ID"]
        self.client_secret = ENV["AZURE_CLIENT_SECRET"]
      end

      def ca_certificate
        response = self.class.get(
          "#{base_url}/certificates/#{certificate_name}?api-version=7.0",
          headers: { Authorization: "Bearer #{access_token}" }
        )

        Signer::Containers::Certificate.from_bytes Base64.urlsafe_decode64(response["cer"])
      end

      def issuer
        ca_certificate.subject
      end

      def sign(csr)
        digest = OpenSSL::Digest::SHA256.new.digest(csr.to_der)

        response = self.class.post(
          "#{base_url}/keys/#{certificate_name}/sign?api-version=7.0",
          format: :json,
          headers: { Authorization: "Bearer #{access_token}", "Content-Type" => "application/json" },
          body: { alg: "RS256", value: Base64.urlsafe_encode64(digest) }.to_json
        )

        Base64.urlsafe_decode64(response["value"])
      end

      private

      def access_token
        @access_token ||= begin
          response = self.class.post(
            "https://login.microsoftonline.com/#{tenant_id}/oauth2/token",
            multipart: true,
            body: {
              client_id: client_id, client_secret: client_secret,
              grant_type: "client_credentials", resource: "https://vault.azure.net"
            }
          )

          JSON.parse(response.body)["access_token"]
        end
      end
    end
  end
end

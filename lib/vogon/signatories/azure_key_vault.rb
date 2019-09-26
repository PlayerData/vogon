# frozen_string_literal: true

# rubocop:disable Metrics/ParameterLists

require "httparty"

module Vogon
  module Signatories
    class AzureKeyVault
      include HTTParty

      attr_accessor :base_url, :certificate_name, :tenant_id, :client_id, :client_secret

      def initialize(
        base_url:, certificate_name:, access_token: nil,
        tenant_id: nil, client_id: nil, client_secret: nil
      )
        self.base_url = base_url
        self.certificate_name = certificate_name

        self.tenant_id = tenant_id
        self.client_id = client_id
        self.client_secret = client_secret

        @access_token = access_token
      end

      def ca_certificate
        response = self.class.get(
          "#{base_url}/certificates/#{certificate_name}?api-version=7.0",
          headers: { Authorization: "Bearer #{access_token}" }
        )

        Vogon::Containers::Certificate.from_bytes Base64.urlsafe_decode64(response["cer"])
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
        @access_token ||= fetch_access_token
      end

      def fetch_access_token
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

# rubocop:enable Metrics/ParameterLists

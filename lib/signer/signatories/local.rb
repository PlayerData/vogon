# frozen_string_literal: true

module Signer
  module Signatories
    class Local
      attr_accessor :ca_cert, :ca_key

      def initialize(ca_key_file:, ca_cert_file:)
        self.ca_key = OpenSSL::PKey::RSA.new(File.read(ca_key_file))
        self.ca_cert = Signer::Containers::Certificate.from_bytes File.read(ca_cert_file)
      end

      def issuer
        ca_cert.subject
      end

      def sign(csr)
        digest = OpenSSL::Digest::SHA256.new

        ca_key.sign(digest, csr.to_der)
      end
    end
  end
end

# frozen_string_literal: true

class Signer
  module Containers
    class Certificate
      def initialize(bytes)
        ossl_req = OpenSSL::X509::Certificate.new bytes
        self.asn = OpenSSL::ASN1.decode(ossl_req)
      end

      def subject
        asn.value[0].value[4]
      end

      private

      attr_accessor :asn
    end
  end
end

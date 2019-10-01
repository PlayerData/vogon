# frozen_string_literal: true

module Vogon
  module Containers
    class Request
      def initialize(bytes)
        self.ossl_req = OpenSSL::X509::Request.new bytes
        self.asn = OpenSSL::ASN1.decode(ossl_req)
      end

      def subject
        asn.value[0].value[1]
      end

      def subject_public_key
        asn.value[0].value[2]
      end

      def to_der
        ossl_req.to_der
      end

      private

      attr_accessor :asn, :ossl_req
    end
  end
end

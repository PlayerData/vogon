# frozen_string_literal: true

class Signer
  module Containers
    class Certificate
      def self.from_bytes(bytes)
        ossl_crt = OpenSSL::X509::Certificate.new bytes
        asn = OpenSSL::ASN1.decode(ossl_crt)

        new(
          subject: asn.value[0].value[4],
          signature: asn.value[2]
        )
      end

      attr_accessor :serial_number, :signing_alg, :issuer,
                    :validity, :subject, :subject_public_key,
                    :signature

      def initialize(attributes = {})
        attributes.map do |attribute, value|
          send("#{attribute}=", value)
        end
      end

      def to_asn
        OpenSSL::ASN1::Sequence.new([tbs_cert_asn, signing_alg_asn, signature_asn])
      end

      def to_der
        to_asn.to_der
      end

      private

      def serial_number_asn
        OpenSSL::ASN1::Integer.new(serial_number, 2)
      end

      def signing_alg_asn
        OpenSSL::ASN1::Sequence.new(
          [
            OpenSSL::ASN1::ObjectId.new(signing_alg, 6),
            OpenSSL::ASN1::Null.new(nil)
          ]
        )
      end

      def validity_asn
        OpenSSL::ASN1::Sequence.new(
          [
            OpenSSL::ASN1::UTCTime.new(validity[:from], 23),
            OpenSSL::ASN1::UTCTime.new(validity[:to], 23)
          ]
        )
      end

      def tbs_cert_asn
        OpenSSL::ASN1::Sequence.new(
          [
            serial_number_asn,
            signing_alg_asn,
            issuer,
            validity_asn,
            subject,
            subject_public_key
          ]
        )
      end

      def signature_asn
        OpenSSL::ASN1::BitString.new(signature, 3)
      end
    end
  end
end

# frozen_string_literal: true

require "sinatra/base"

module Signer
  class Server < Sinatra::Base
    post "/sign" do
      Signatory = Signer::Signatories.const_get(params[:signatory])

      signatory = Signatory.new(File.join(__dir__, "../../spec/fixtures/ca.key"), File.join(__dir__, "../../spec/fixtures/ca.crt"))
      csr = request.body.read.to_s

      crt = Signer.sign(csr, signatory, params[:days].to_i)
      crt.to_pem
    end
  end
end

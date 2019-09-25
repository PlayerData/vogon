# frozen_string_literal: true

require "active_support/inflector"

require "sinatra/base"

module Signer
  class Server < Sinatra::Base
    post "/sign" do
      signatory_name = params[:signatory]
      signatory_class = Signer::Signatories.const_get(signatory_name)

      signatory = signatory_class.new(signatory_settings(signatory_name))

      csr = request.body.read.to_s

      crt = Signer.sign(csr, signatory, params[:days].to_i)
      crt.to_pem
    end

    private

    def settings_file
      @settings_file ||= YAML.load_file(ENV["SIGNER_SERVER_CONFIG"])
    end

    def signatory_settings(signatory_name)
      signatory_name_score = signatory_name.underscore

      from_file = settings_file[:signatories][signatory_name]
      from_params = params.select { |k, _v| k.include?(signatory_name_score) }.transform_keys do |key|
        key.downcase.gsub("#{signatory_name_score}_", "").to_sym
      end

      from_params.merge(from_file)
    end
  end
end

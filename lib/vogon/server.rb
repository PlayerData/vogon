# frozen_string_literal: true

require "active_support/inflector"
require "sinatra/base"
require "yaml"

require "vogon"

module Vogon
  class Server < Sinatra::Base
    post "/sign" do
      if signatory.nil?
        status 422
        return { errors: { signatory: "is not available" } }.to_json
      end

      csr = Vogon::Containers::Request.new request.body.read.to_s
      request = Vogon::SigningRequest.new(csr, params[:days].to_i)

      if request.invalid?
        status 422
        return { errors: request.errors.to_h }.to_json
      end

      crt = request.sign(signatory)
      crt.to_pem
    end

    private

    def settings_file
      @settings_file ||= begin
        config_file_path = ENV["VOGON_SERVER_CONFIG"]

        raise "VOGON_SERVER_CONFIG not set" if config_file_path.blank?

        YAML.load_file(config_file_path)
      end
    rescue Errno::ENOENT
      raise "VOGON_SERVER_CONFIG does not exist"
    end

    def signatory
      enabled_signatories = settings_file[:signatories].keys
      signatory_name = params[:signatory]

      return nil unless enabled_signatories.include?(signatory_name)

      signatory_class = Vogon::Signatories.const_get(signatory_name)
      signatory_class.new(signatory_settings(signatory_name))
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

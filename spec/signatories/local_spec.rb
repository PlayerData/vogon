# frozen_string_literal: true

require "base64"

RSpec.describe Signer::Signatories::Local do
  subject(:signatory) { Signer::Signatories::Local.new(fixture("ca.key"), fixture("ca.crt")) }

  it "gets the issuer name" do
    ca_cert = OpenSSL::X509::Certificate.new File.read(fixture("ca.crt"))

    expect(signatory.issuer.to_der).to eq ca_cert.subject.to_der
  end

  it "signs a CSR" do
    csr = Signer::Containers::Request.new File.read(fixture("example.csr"))

    expect(Base64.encode64(signatory.sign(csr))).to eq(
      <<~SIGNATURE
        AJguY4sRE8MCTR1mnnlPc2tWub/GyaNMcoc/vnPEcDiDLzVKaZALEef9RxxK
        7031BjDOaljqgkKgeHjF1qyHoDgd5KlJyrYK4J53iTyLkkQNAhUgsVuHARsv
        9xVbz5CBin3wNgY3JRIWMe2neU37n23k4CnOMUZUvLGuziSnPAXkyZFQmmCZ
        h/UJMu04dtiHTbIziSBclJmKIRvAv/ksY+3OdC3kCklcojWTihTjmr2hSXW+
        VW6GbZSMwmSWA6mZTDWIH4dWINpzv25jiFo1rJWEfDqdSLIJIxJil6ycJlFA
        K1q0o1qAHq+GRJ20nSH1lc+7CxB27B8332IRrV0MeQ==
      SIGNATURE
    )
  end
end

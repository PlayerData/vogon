# frozen_string_literal: true

RSpec.describe Vogon::Signatories::Local do
  subject(:signatory) do
    Vogon::Signatories::Local.new(
      ca_key_file: fixture("ca.key"),
      ca_cert_file: fixture("ca.crt")
    )
  end

  it "gets the issuer name" do
    ca_cert = OpenSSL::X509::Certificate.new File.read(fixture("ca.crt"))

    expect(signatory.issuer.to_der).to eq ca_cert.subject.to_der
  end

  it "signs a CSR" do
    csr = Vogon::Containers::Request.new File.read(fixture("example.csr"))

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

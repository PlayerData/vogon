# Vogon

This is Vogon, a gem and lightweight HTTP server to allow signing of
Certificate Signing Requests (CSRs) with remote certificates.

Caution: Vogon is very much alpha level software. Use at your own risk.

## Why?

At PlayerData, we need our own PKI for signing embedded device software updates.
We want to keep our root certificate somewhere nice and secure, and use more disposable
and short-lived certificates for signing update packages.

Many cloud providers provide a certificate management solution of some variety
(e.g. Azure Key Vault, Google Cloud Key Management Service, Amazon Key Management Service, etc).
For reasons we don't understand, most aren't able to act as a certificate authority (i.e. they
don't provide the ability to sign a CSR).
(Amazon KMS does, but for $$$).

Vogon takes a CSR, constructs a new certificate to be signed, sends it off to your chosen
signatory to be signed, and returns a certificate.

## What Vogon Doesn't Do

All of the complex things around being a CA, e.g:
* certificate revocation lists
* certificate transparency

## Supported Signatories

Currently only Azure Key Vault is supported, along with a Local signatory for testing purposes.

## Server Usage

TODO

## Gem Usage

```rb
signatory = Vogon::Signatories::AzureKeyVault.new(
  base_url: "https://vault-name.vault.azure.net",
  certificate_name: "cert-name",
  tenant_id: "tennant-id",
  client_id: ENV["AZURE_KEY_VAULT_CLIENT_ID"],
  client_secret: ENV["AZURE_KEY_VAULT_CLIENT_SECRET"],
)

# or

signatory = Vogon::Signatories::Local.new(
  ca_key_file: "ca.key", ca_cert_file: "ca.crt"
)

csr = Vogon::Containers::Request.new File.read("example.csr")
request = Vogon::SigningRequest.new(csr, params[:days].to_i)

crt = request.sign(signatory)
crt.to_pem
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/vogon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vogon project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/vogon/blob/master/CODE_OF_CONDUCT.md).

## Why Vogon?

This entire process seems somewhat bureaucratic.
As such, the project is named after the Vogons - the galactic government's bureaucrats.

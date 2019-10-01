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

### Running

Create a `config.ru`:

```
require 'vogon/server'
run Vogon::Server
```

Use a rack web server to boot the app:

```
puma config.ru
```

### Config

You must set the VOGON_SERVER_CONFIG environment variable to point to a valid config file.

The vogon config file looks something like this:

```yml
# vogon.yml

:signatories:
  # Local:
  #   :ca_key_file: spec/fixtures/ca.key
  #   :ca_cert_file: spec/fixtures/ca.crt

  AzureKeyVault:
    :base_url: https://vault-name.vault.azure.net
    :certificate_name: cert-name
```

Config can also be set as URL parameters when using the API.
Config in `vogon.yaml` takes precedence over URL parameters

Config options:

| Local Signatory | | |
|-----------------|-|-|
| ca_key_file     | required | Path to the key file associated with the CA's certificate |
| ca_cert_file    | required | Path to the CA's certificate                              |

| Azure Key Vault Signatory | | |
|---------------------------|-|-|
| base_url                  | required | Base URL for the vault |
| certificate_name          | required | Name of the certificate within the vault to be used as a CA. It's assumed that its associated key has the same name |
| tenant_id                 | optional | Tenant ID for the Azure Active Directory we're authenticating against. Required if `access_token` is not specified
| client_id                 | optional | Client ID for the Service Principle being used for authentication. Required if `access_token` is not specified
| client_secret             | optional | Client ID for the Service Principle being used for authentication. Required if `access_token` is not specified
| access_token              | optional | The access token to be used to access AKV. May be omitted if `tenant_id`, `client_id` and `client_secret` are specified, in which case Vogon will perform the OAuth2 dance for you.

### The API

Vogon Server has a single POST endpoint, `/sign`.

The following URL parameters must be included:

| | |
|-|-|
| signatory | One of `Local` or `AzureKeyVault` |
| days      | The number of days the certificate should be valid for

Config options may be specified as additional URL parameters, prefixed by the signatory name in snakecase.

The request body should be the CSR to be signed.

A successful response will be the signed certificate with status code `200`.

Any other status code should be treated as an error. The response body will be of the form:

```json
{
  "errors": {
    "valid_days": "must be less than 180"
  }
}
```

Example request:

```
POST /sign?signatory=AzureKeyVault&days=90&azure_key_vault_tenant_id=tenant-id&azure_key_vault_client_id=client-id&azure_key_vault_client_secret=client-secret
```

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
request = Vogon::SigningRequest.new(csr, 60)

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

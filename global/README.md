# Global configuration

This houses the global, shared configuration such as the `dmtr.host` domain
DNS configuration and the Cloudflare load balancing used for creating tunnel
connections to each provider.

If you need support in fetching your credentials or in creating a new tunnel,
reach out to @wolf31o2 or the `#demeter-fabric` channel in the TxPipe Discord.

## Fetching credentials

To fetch credentials for an existing tunnel, configure the backend, then run
this terraform command:

```bash
terraform show -json | \
  jq -r '.values.root_module.resources | to_entries[] | select( .value.address=="cloudflare_tunnel.this[\"txpipe\"]") | .value.values.tunnel_token'
```

## Creating a new tunnel

To create a new tunnel, you will need to configure the backend and several
variables for terraform.

- `cloudflare_account_id`: Cloudflare account for dmtr.host
- `cloudflare_zone_id`: zone ID for dmtr.host
- `cloudflare_zone_name`: this is `dmtr.host`
- `cloudflare_tunnels`: this is a list of provider maps, which contain name
  and secret keys. Secrets are a base64-encoded string. We use 32-bit alnum
  values.

Example:
```
cloudflare_tunnels = [
  {
    name   = "blinklabs"
    secret = "somebase64encodedstring"
  },
  {
    name   = "txpipe"
    secret = "differentbase64encodedstring"
  },
]
```

If you have all of the tunnel secrets, apply as normal. Otherwise, you can use
a targeted apply to only the new tunnel.

```bash
terraform apply -target=cloudflare_tunnel.this[\"txpipe\"]
```

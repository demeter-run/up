# Global configuration

This houses the global, shared configuration such as the `dmtr.host` domain
DNS configuration and the Cloudflare load balancing used for creating tunnel
connections to each provider.

## Fetching credentials

To fetch credentials for a tunnel, configure the backend, then run this:

```bash
terraform show -json | jq -r '.values.root_module.resources | to_entries[] | select( .value.address=="cloudflare_tunnel.this[\"txpipe\"]") | .value.values.tunnel_token'
```

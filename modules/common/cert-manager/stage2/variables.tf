variable "acme_account_email" {
  type    = string
  default = "something@example.com"
}

variable "ingress_class" {
  type    = string
  default = "alb"
}

variable "cloudflare_token" {
  type        = string
  default     = null
  description = <<EOF
Optional Cloudflare API token.
If provided, will use Cloudflare for DNS challenges.
Otherwise, it defaults to AWS Route53.
EOF
}

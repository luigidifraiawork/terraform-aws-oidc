variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "idp_tls_url" {
  description = "The TLS URL of the identity provider"
  type        = string
  # Avoid using https scheme because the Hashicorp TLS provider has started following redirects starting from v4.
  # See https://github.com/hashicorp/terraform-provider-tls/issues/249
}

variable "idp_url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  type        = string
}

variable "client_id" {
  description = "This is the value that's sent as the client_id parameter on OAuth requests"
  type        = string
}

variable "subjects" {
  description = "List of OIDC subjects that are permitted by the trust policy"
  type        = list(string)
}

variable "description" {
  description = "OIDC role description"
  type        = string
  default     = null
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for the OIDC role"
  type        = string
  default     = null
}

variable "force_detach_policies" {
  description = "Whether policies should be detached from the OIDC role when destroying"
  type        = bool
  default     = true
}

variable "deploy_role_arns" {
  description = "ARNs of the roles the OIDC role can assume for deployment purposes"
  type        = list(string)
}

variable "tags" {
  description = "A map of additional tags to add to all resources"
  type        = map(string)
  default     = {}
}

config {
    module = true
    force = false
    disabled_by_default = false
    varfile = ["terraform.tfvars"]
}

rule "terraform_required_providers" {
  enabled = false
}

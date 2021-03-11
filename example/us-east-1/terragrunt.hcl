include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/vainkop/terraform-aws-wireguard?ref=v1.2.0"
}

locals { common_vars = yamldecode(file("values.yaml")) }

inputs = local.common_vars

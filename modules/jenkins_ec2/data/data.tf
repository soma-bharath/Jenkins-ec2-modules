data "aws_vpc" "spaces-prod-app-1" {

  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spaces-prod-app-1.id]
  }
  filter {
    name   = "tag:Subnet-Type"
    values = ["private"]
  }
}

data "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spaces-prod-app-1.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

data "aws_subnet" "spaces-prod-public-1c" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spaces-prod-app-1.id]
  }
  filter {
    name   = "tag:Name"
    values = ["spaces-prod-public-1c"]
  }
}

data "aws_subnet" "spaces-prod-app-1a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spaces-prod-app-1.id]
  }
  filter {
    name   = "tag:Name"
    values = ["spaces-prod-app-1a"]
  }
}

data "aws_subnet" "public_subnets" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_kms_key" "my_key" {
  key_id = var.kms_key_id #enter your existing kms key id
}



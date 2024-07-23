data "aws_vpc" "main_vpc" {

  filter {
    name   = "tag:Name"
    values = ["spaces-prod-app-1"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["spaces-prod-app*"]
  }
}

data "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["spaces-prod-public*"]
  }
}

data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["spaces-prod-public-1a"]
  }
}

data "aws_subnet" "private_subnet_1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
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
/*
data "aws_route53_zone" "hosted_zone" {
  name = "devgov.ciscospaces.io" # Replace with your hosted zone name
}
*/
data "aws_route_tables" "private" {
  filter {
    name   = "tag:Name"
    values = ["Space-prod-private-route-table-1"]
  }
}

/*
data "aws_kms_key" "my_key" {
  key_id = "arn:aws:kms:region:account-id:key/key-id" #enter your existing kms key id
}
*/

resource "aws_vpc" "this" {
  for_each = { for project in local.projects : "${project.name}" => project }

  cidr_block           = each.value.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    "Name" = each.value.name
  }
}

resource "aws_internet_gateway" "this" {
  for_each = { for project in local.projects : "${project.name}" => project }

  vpc_id = aws_vpc.this[each.value.name].id

  tags = {
    "Name" = each.value.name
  }
}

resource "aws_subnet" "public" {
  for_each = { for subnet in local.subnets : "${subnet.project}_public_${subnet.az}" => subnet }

  vpc_id                  = aws_vpc.this[each.value.project].id
  cidr_block              = cidrsubnet(aws_vpc.this[each.value.project].cidr_block, 8, each.value.index)
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    "Name" = format(
      "${each.value.project}-public-subnet-%s",
      substr(each.value.az, -1, 1),
    )
  }
}

resource "aws_route" "internet" {
  for_each = { for project in local.projects : "${project.name}" => project }

  route_table_id         = aws_vpc.this[each.value.name].default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[each.value.name].id
}
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge (
    var.vpc_tags,
    local.common_tags
  ) 
}

resource "aws_internet_gateway" "gway" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.intgw_tags,
    local.common_tags,
  ) 
}

resource "aws_subnet" "frounttir" {
  count = length(var.cidrs_frounttir)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidrs_frounttir[count.index]
  availability_zone = local.availablez[count.index]
  map_public_ip_on_launch = true

  tags = merge (
    var.subnet_frounttir_tags,
    local.common_tags,
  
   {
    Name = "${local.common_name}-frounttir-${split("-", local.availablez[count.index])[2]}"
  }
  )
}

resource "aws_subnet" "apptire" {
  count = length(var.cidrs_apptire)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidrs_apptire[count.index]
  availability_zone = local.availablez[count.index]
   map_public_ip_on_launch = false

  tags = merge (
    var.subnet_apptire_tags,
    local.common_tags,
  
   {
    Name = "${local.common_name}-apptire-${split("-", local.availablez[count.index])[2]}"
  }
  )
}

resource "aws_subnet" "dbtire" {
  count = length(var.cidrs_dbtire)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidrs_dbtire[count.index]
  availability_zone = local.availablez[count.index]
   map_public_ip_on_launch = false

  tags = merge (
    var.subnet_dbtire_tags,
    local.common_tags,
  
   {
    Name = "${local.common_name}-dbtire-${split("-", local.availablez[count.index])[2]}"
  }
  )
}

resource "aws_route_table" "frounttir" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.front_rout_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-fronttire"
    }
  )
}

resource "aws_route_table" "apptiretir" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.apptire_rout_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-apptire"
    }
  )
}

resource "aws_route_table" "dbtir" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.dbtire_rout_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-dbtire"
    }
  )
}

resource "aws_route_table_association" "fronttire" {
  count = length(var.cidrs_frounttir)
  subnet_id      = aws_subnet.frounttir[count.index].id
  route_table_id = aws_route_table.frounttir.id
}

resource "aws_route_table_association" "apptiretir" {
  count = length(var.cidrs_apptire)
  subnet_id      = aws_subnet.apptire[count.index].id
  route_table_id = aws_route_table.apptiretir.id
}

resource "aws_route_table_association" "dbtir" {
  count = length(var.cidrs_dbtire)
  subnet_id      = aws_subnet.dbtire[count.index].id
  route_table_id = aws_route_table.dbtir.id
}

resource "aws_eip" "nat_ip" {
  domain = "vpc"

  tags = merge (
    var.eip_tags,
    local.common_tags,

  {
    Name = "${local.common_name}-nat-static-ip"
  }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.frounttir[1].id # Must be placed in a public subnet

  tags = merge (
    var.net_tags,
    local.common_tags                                
  )
  # Recommended explicit dependency to ensure correct deployment order
  depends_on = [aws_internet_gateway.gway]
}

resource "aws_route" "public_rt" {

    route_table_id         = aws_route_table.frounttir.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gway.id
  
}

resource "aws_route" "apptire_nat_route" {
  route_table_id         = aws_route_table.apptiretir.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route" "dbtire_nat_route" {
  route_table_id         = aws_route_table.dbtir.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

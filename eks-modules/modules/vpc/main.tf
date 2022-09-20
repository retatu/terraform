resource "aws_vpc" "new_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnets" {
  count      = 2
  vpc_id     = aws_vpc.new_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "new-rtb" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.prefix}-rtb"
  }
  depends_on = [aws_internet_gateway.new-igw]
}

resource "aws_route_table_association" "new-rtb-association" {
  count          = 2
  subnet_id      = aws_subnet.subnets.*.id[count.index]
  route_table_id = aws_route_table.new-rtb.id
}

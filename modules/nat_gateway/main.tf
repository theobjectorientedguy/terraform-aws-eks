resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id  # Pass the public subnet ID

  tags = {
    Name = "nat-gateway"
  }
  
  depends_on = [aws_internet_gateway.igw]
}

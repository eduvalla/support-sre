data "aws_availability_zones" "azs" {
  provider = aws
  state    = "available"
}
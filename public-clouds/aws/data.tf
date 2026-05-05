data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "my_public_ip_address" {
  url = "https://ipv4.icanhazip.com/"
}

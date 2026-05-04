data "aws_ami" "opensuse_leap" {
  count       = var.certified_os_image ? 0 : 1
  most_recent = true
  # Owner ID for openSUSE Marketplace images
  owners = ["679593333241"]

  filter {
    name = "name"
    # Matches the specific version and architecture you provided
    values = ["openSUSE-Leap-15*-*x86_64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "my_public_ip_address" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  availability_zone = "eu-west-2a"
  ec2_username      = "ubuntu" # Must be ubuntu
  deployer_ip       = data.http.deployer_ip.response_body
}

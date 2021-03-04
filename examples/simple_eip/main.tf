resource "aws_eip" "wireguard" {
  vpc = true
  tags = {
    Name = "wireguard"
  }
}

module "wireguard" {
  region        = "us-east-1"
  source        = "vainkop/wireguard/aws"
  version       = "1.0.1"
  ssh_key_id    = "ssh-key-01"
  instance_type = "t2.medium"
  vpc_id        = "vpc-0e604d4a2e308d05e"
  subnet_ids    = ["subnet-0786aef3b08de4086"]
  use_eip       = true
  eip_id        = aws_eip.wireguard.id
  wg_server_net = "10.8.0.1/24"
  wg_clients = [
    {
      name = "client1"
      public_key = "QHdbO9TThkXfCJLZWLaSCMFcIylqiyJdm02CYHLWFmI="
      client_ip = "10.8.0.2/32"
    },
    {
      name = "client1"
      public_key = "4BGwG/o0qCiPUstTsDY5ikVzkGZyfEeEuPY6380u0Eg="
      client_ip = "10.8.0.3/32"
    },
    {
      name = "client3"
      public_key = "UKltTV3qmsrmp7DssvP+qAd2m1nBpVXRrsL3AxqsJ2Q="
      client_ip = "10.8.0.4/32"
    },
  ]
}
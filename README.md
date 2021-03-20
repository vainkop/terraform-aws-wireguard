# terraform-aws-wireguard

A Terraform module to deploy a WireGuard VPN server on AWS. It can also be used to run one or more servers behind a loadbalancer, for redundancy.  

The module is "Terragrunt ready" & supports multi region deployment & values in yaml format. Please see example here: [example/](example/)  

## Prerequisites
Before using this module, you'll need to generate a key pair for your server and client, which cloud-init will source and add to WireGuard's configuration.

- Install the WireGuard tools for your OS: https://www.wireguard.com/install/
- Generate a key pair for each client
  - `wg genkey | tee client1-privatekey | wg pubkey > client1-publickey`
- Generate a key pair for the server
  - `wg genkey | tee server-privatekey | wg pubkey > server-publickey`
- Add each client's public key, along with the next available IP address to the wg_clients list. See Usage for details.

## Variables
| Variable Name | Type | Required |Description |
|---------------|-------------|-------------|-------------|
|`subnet_ids`|`list`|Yes|A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list.|
|`ssh_key_id`|`string`|Yes|A SSH public key ID to add to the VPN instance.|
|`vpc_id`|`string`|Yes|The VPC ID in which Terraform will launch the resources.|
|`env`|`string`|Optional - defaults to `prod`|The name of environment for WireGuard. Used to differentiate multiple deployments.|
|`use_eip`|`bool`|Optional|Whether to attach an [Elastic IP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) address to the VPN server. Useful for avoiding changing IPs.|
|`eip_id`|`string`|Optional|When `use_eip` is enabled, specify the ID of the Elastic IP to which the VPN server will attach.|
|`use_ssm`|`bool`|Optional|Use SSM Parameter Store for the VPN server Private Key.|
|`wg_server_private_key`|`string`|Yes - defaults to static value in `/etc/wireguard/wg0.conf`| Static value or The Parameter Store key to use for the VPN server Private Key.|
|`target_group_arns`|`string`|Optional|The Loadbalancer Target Group to which the vpn server ASG will attach.|
|`additional_security_group_ids`|`list`|Optional|Used to allow added access to reach the WG servers or allow loadbalancer health checks.|
|`asg_min_size`|`integer`|Optional - default to `1`|Number of VPN servers to permit minimum, only makes sense in loadbalanced scenario.|
|`asg_desired_capacity`|`integer`|Optional - default to `1`|Number of VPN servers to maintain, only makes sense in loadbalanced scenario.|
|`asg_max_size`|`integer`|Optional - default to `1`|Number of VPN servers to permit maximum, only makes sense in loadbalanced scenario.|
|`instance_type`|`string`|Optional - defaults to `t2.micro`|Instance Size of VPN server.|
|`wg_server_net`|`cidr address and netmask`|Yes|The server ip allocation and net - wg_clients entries MUST be in this netmask range.|
|`wg_clients`|`list`|Yes|List of client objects with IP and public key. See Usage for details. See Examples for formatting.|
|`wg_server_port`|`integer`|Optional - defaults to `51820`|Port to run wireguard service on, wireguard standard is 51820.|
|`wg_persistent_keepalive`|`integer`|Optional - defaults to `25`|Regularity of Keepalives, useful for NAT stability.|
|`ami_id`|`string`|Optional - defaults to the newest Ubuntu 20.04 AMI|AMI to use for the VPN server.|
|`wg_server_interface`|`string`|Optional - defaults to eth0|Server interface to route traffic to for installations forwarding traffic to private networks.|
|`use_route53`|`bool`|Optional|Create Route53 record for Wireguard server.|
|`route53_hosted_zone_id`|`string`|Optional - if use_route53 is not used.|Route53 Hosted zone ID for Wireguard server Route53 record.|
|`route53_record_name`|`string`|Optional - if use_route53 is not used.|Route53 Record Name for Wireguard server.|